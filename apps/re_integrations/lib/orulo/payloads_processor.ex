defmodule ReIntegrations.Orulo.PayloadsProcessor do
  @moduledoc """
  Module to process payloads into internal representations.
  """

  alias ReIntegrations.{
    Cloudinary,
    Orulo.BuildingPayload,
    Orulo.ImagePayload,
    Orulo.JobQueue,
    Orulo.Mapper,
    Repo
  }

  alias Ecto.{
    Multi
  }

  def insert_development_from_building_payload(multi, building_uuid) do
    with building <- Repo.get(BuildingPayload, building_uuid),
         address_params <- Mapper.building_payload_into_address_params(building),
         development_params <- Mapper.building_payload_into_development_params(building),
         {:ok, transaction} <-
           insert_transaction(multi, address_params, development_params, building_uuid) do
      {:ok, transaction}
    else
      err -> err
    end
  end

  defp insert_transaction(multi, address_params, development_params, building_uuid) do
    multi
    |> Multi.run(:insert_address, fn _repo, _changes ->
      insert_address(address_params)
    end)
    |> Multi.run(:insert_development, fn _repo, %{insert_address: new_address} ->
      insert_development(development_params, new_address)
    end)
    |> JobQueue.enqueue(:fetch_images, %{
      "type" => "fetch_images_from_orulo",
      "uuid" => building_uuid
    })
    |> Repo.transaction()
  end

  defp insert_address(params), do: Re.Addresses.insert_or_update(params)

  defp insert_development(params, address), do: Re.Developments.insert(params, address)

  def insert_images_from_image_payload(_multi, external_uuid, orulo_id) do
    %{payload: %{"images" => image_payload}} = Repo.get(ImagePayload, external_uuid)

    image_payload
    |> extract_url_from_payload()
    |> upload_images()
    |> save_images(orulo_id)
  end

  defp upload_images(image_urls), do: Cloudinary.Client.upload(image_urls)

  defp extract_url_from_payload(image_payload) do
    image_payload
    |> Enum.map(fn image -> Map.get(image, "1024x1024") end)
    |> Enum.map(fn image_url -> image_url end)
  end

  defp save_images(image_urls, orulo_id) do
    params =
      Enum.map(image_urls, fn {:ok, url} -> Map.get(url, :url) end)
      |> Enum.map(&extract_filename/1)
      |> Enum.map(fn image_upload -> %{filename: image_upload} end)

    development =
      Re.Repo.get_by!(Re.Development, orulo_id: orulo_id)
      |> Re.Repo.preload([:images])

    params
    |> Enum.map(&Re.Images.insert(&1, development))
  end

  defp extract_filename(filename) do
    filename
    |> String.split("/")
    |> List.last()
  end
end
