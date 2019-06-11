defmodule ReIntegrations.Orulo.PayloadProcessors.Buildings do
  @moduledoc """
  Module to process building payloads into developments and adrresses.
  """
  alias Ecto.Multi

  alias ReIntegrations.{
    Orulo.BuildingPayload,
    Orulo.JobQueue,
    Orulo.Mapper,
    Repo
  }

  def insert_development_from_building_payload(multi, building_uuid) do
    building = Repo.get(BuildingPayload, building_uuid)

    multi
    |> insert_address(building)
    |> insert_development(building)
    |> enqueue_image_job(building)
    |> enqueue_tag_job(building)
    |> Repo.transaction()
  end

  defp insert_address(multi, building) do
    Multi.run(multi, :insert_address, fn _repo, _changes ->
      building
      |> Mapper.building_payload_into_address_params()
      |> Re.Addresses.insert_or_update()
    end)
  end

  defp insert_development(multi, building) do
    Multi.run(multi, :insert_development, fn _repo, %{insert_address: address} ->
      building
      |> Mapper.building_payload_into_development_params()
      |> Re.Developments.insert(address)
    end)
  end

  defp enqueue_image_job(multi, building) do
    JobQueue.enqueue(multi, :fetch_images, %{
      "type" => "fetch_images_from_orulo",
      "external_id" => building.external_id
    })
  end

  defp enqueue_tag_job(multi, building) do
    JobQueue.enqueue(multi, :process_tags, %{
      "type" => "process_orulo_tags",
      "external_id" => building.uuid
    })
  end
end
