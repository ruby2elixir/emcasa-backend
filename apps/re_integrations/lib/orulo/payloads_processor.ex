defmodule ReIntegrations.Orulo.PayloadsProcessor do
  @moduledoc """
  Module to process payloads into internal representations.
  """

  # @claudinary_client Cloudex
  @cloudinary_client Application.get_env(:re_integrations, :cloudinary_client, Cloudex)

  alias ReIntegrations.{
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

  def insert_images_from_image_payload(_multi, external_uuid, development_uuid) do
    %{payload: %{"images" => image_payload}} = Repo.get(ImagePayload, external_uuid)

    image_url_list =
      image_payload
      |> Enum.map(fn image -> Map.get(image, "1024x1024") end)
      |> Enum.map(fn image_url -> image_url end)

    image_url_list
    |> upload_images()
    |> save_images(development_uuid)
  end

  defp upload_images(image_list) do
    upload_response = @cloudinary_client.upload(image_list)

    {success_uploads, failed_uploads} =
      Enum.split_with(upload_response, fn response -> success_response?(response) end)

    log_failed_response(failed_uploads)

    success_uploads
  end

  defp success_response?({:ok, _response}), do: true
  defp success_response?(_), do: false

  defp save_images(image_urls, _dev_uuid) do
    Enum.map(image_urls, fn {:ok, url} -> Map.get(url, :url) end)
    |> Enum.map(&extract_filename/1)
    |> Enum.map(fn image_upload -> %{filename: image_upload} end)

    # |> Enum.map(&Re.Images.insert(&1, Repo.get!(Re.Development, dev_uuid)))
  end

  defp log_failed_response(uploads), do: uploads

  defp extract_filename(filename) do
    filename
    |> String.split("/")
    |> List.last()
  end
end
