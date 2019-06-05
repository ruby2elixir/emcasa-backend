defmodule ReIntegrations.Orulo.PayloadsProcessor do
  @moduledoc """
  Module to process payloads into internal representations.
  """

  alias Ecto.Multi

  alias Re.Developments

  alias ReIntegrations.{
    Cloudinary,
    Orulo.BuildingPayload,
    Orulo.ImagePayload,
    Orulo.JobQueue,
    Orulo.Mapper,
    Repo
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

  def insert_images_from_image_payload(multi, external_uuid, orulo_id) do
    %{payload: %{"images" => image_payload}} = Repo.get(ImagePayload, external_uuid)

    {:ok, development} = get_development_by_orulo_id(orulo_id)

    images_upload_response =
      image_payload
      |> extract_url_list_from_payload()
      |> upload_images()

    multi
    |> Multi.run(:insert_images, fn _repo, _changes ->
      case images_upload_response do
        [_] ->
          saved_images =
            images_upload_response
            |> extract_images_params_from_response()
            |> save_images(development)

          {:ok, saved_images}

        [] ->
          {:error, "Could not upload development images."}
      end
    end)
    |> Repo.transaction()
  end

  defp upload_images(image_urls), do: Cloudinary.Client.upload(image_urls)

  @resolution "1024x1024"
  defp extract_url_list_from_payload(image_payload) do
    image_payload
    |> Enum.map(fn image -> Map.get(image, @resolution) end)
  end

  defp save_images(image_names, development) do
    image_names
    |> Enum.map(&Re.Images.insert(&1, development))
  end

  defp extract_images_params_from_response(uploaded_images) do
    Enum.map(uploaded_images, &mount_filename_from_response/1)
    |> Enum.map(fn filename -> %{filename: filename} end)
  end

  defp mount_filename_from_response({:ok, %{public_id: public_id, format: format}}),
    do: "#{public_id}.#{format}"

  def get_development_by_orulo_id(orulo_id) do
    case Developments.get_by_orulo_id(orulo_id) do
      {:ok, development} ->
        {:ok, Developments.preload(development, [:images])}

      error ->
        error
    end
  end
end
