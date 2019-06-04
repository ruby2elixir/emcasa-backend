defmodule ReIntegrations.Orulo.PayloadsProcessor do
  @moduledoc """
  Module to process payloads into internal representations.
  """
  alias ReIntegrations.{
    Orulo.BuildingPayload,
    Orulo.ImagePayload,
    Orulo.JobQueue,
    Orulo.Mapper,
    Repo
  }

  alias Ecto.{
    Changeset,
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

  def insert_images_from_image_payload(multi, external_uuid, development_uuid) do
    %{payload: %{"images" => image_payload}} = Repo.get(ImagePayload, external_uuid)

    image_url_list =
      image_payload
      |> Enum.map(fn image -> Map.get(image, "1024x1024") end)
      |> Enum.map(fn image_url -> image_url end)

    save_images(image_url_list, development_uuid)
  end

  def save_images(image_list, dev_uuid) do
    upload_response = Cloudex.upload(image_list)

    {failed_uploads, success_uploads} =
      Enum.split_with(upload_response, fn upload_result -> Map.has_key?(upload_result, :error) end)

    log_failed_response(failed_uploads)

    Enum.map(success_uploads, fn image_upload -> Map.get(image_upload, :url) end)
    |> Enum.map(&extract_filename/1)
    |> Enum.map(fn image_upload -> %{filename: image_upload} end)
    |> Enum.map(&Re.Images.insert(&1, Repo.get!(Re.Development, dev_uuid)))
  end

  def log_failed_response(uploads), do: uploads

  def extract_filename(filename) do
    filename
    |> String.split("/")
    |> List.last()
  end
end
