defmodule ReIntegrations.Orulo do
  @moduledoc """
  Context module to use importers.
  """

  import Ecto.Query, only: [where: 2]
  require Logger

  alias ReIntegrations.{
    Orulo.BuildingPayload,
    Orulo.Client,
    Orulo.ImagePayload,
    Orulo.TypologyPayload,
    Orulo.UnitPayload,
    Orulo.JobQueue,
    Repo
  }

  alias Ecto.{
    Changeset,
    Multi
  }

  def get_building_payload(id) do
    if building_payload_synced?(id) do
      {:error, "Sync already scheduled!"}
    else
      %{"type" => "import_development_from_orulo", "external_id" => id}
      |> JobQueue.new()
      |> Repo.insert()
    end
  end

  def import_development(multi, external_id) do
    multi
    |> Multi.run(:fetch_building, fn _repo, _changes ->
      fetch_building(external_id)
    end)
    |> Multi.run(:insert_building_payload, fn _repo, %{fetch_building: payload} ->
      insert_building_payload(%{external_id: external_id, payload: payload})
    end)
    |> Multi.run(:enqueue_job, fn _repo, %{insert_building_payload: %{uuid: uuid}} ->
      new_job("parse_building_into_development", uuid)
    end)
    |> Repo.transaction()
  end

  defp new_job(type, uuid) do
    %{"type" => type, "uuid" => uuid}
    |> JobQueue.new()
    |> Repo.insert()
  end

  def import_images(multi, external_id) do
    multi
    |> Multi.run(:fetch_images, fn _repo, _changes ->
      fetch_images(external_id)
    end)
    |> Multi.run(:insert_images_payload, fn _repo, %{fetch_images: payload} ->
      insert_images_payload(%{external_id: external_id, payload: payload})
    end)
    |> Multi.run(:enqueue_job, fn _repo, %{insert_images_payload: %{uuid: uuid}} ->
      new_job("parse_images_payloads_into_images", uuid)
    end)
    |> Repo.transaction()
  end

  def import_typologies(multi, id) when is_integer(id),
    do: import_typologies(multi, Integer.to_string(id))

  def import_typologies(multi, id) do
    multi
    |> Multi.run(:fetch_typologies, fn _repo, _changes ->
      fetch_typologies(id)
    end)
    |> Multi.run(:insert_typologies_payload, fn _repo, %{fetch_typologies: payload} ->
      insert_typologies_payload(%{building_id: id, payload: payload})
    end)
    |> Multi.run(:enqueue_job, fn _repo, %{insert_typologies_payload: %{uuid: uuid}} ->
      new_job("fetch_units", uuid)
    end)
    |> Repo.transaction()
  end

  defp fetch_building(external_id) do
    with {:ok, %{body: body}} <- Client.get_building(external_id) do
      Jason.decode(body)
    end
  end

  defp fetch_images(external_id) do
    with {:ok, %{body: body}} <- Client.get_images(external_id) do
      Jason.decode(body)
    end
  end

  defp fetch_typologies(external_id) do
    with {:ok, %{body: body}} <- Client.get_typologies(external_id) do
      Jason.decode(body)
    end
  end

  defp insert_building_payload(params) do
    %BuildingPayload{}
    |> BuildingPayload.changeset(params)
    |> Repo.insert()
  end

  defp insert_images_payload(params) do
    %ImagePayload{}
    |> ImagePayload.changeset(params)
    |> Repo.insert()
  end

  defp insert_typologies_payload(params) do
    %TypologyPayload{}
    |> TypologyPayload.changeset(params)
    |> Repo.insert()
  end

  def bulk_insert_unit_payloads(%Multi{} = multi, building_id, responses) do
    building_id
    |> generate_unit_multies(responses)
    |> Enum.reduce(multi, fn unit_multi, acc ->
      Multi.prepend(acc, unit_multi)
    end)
    |> ReIntegrations.Repo.transaction()
  end

  defp generate_unit_multies(building_id, responses) do
    Enum.map(responses, fn response ->
      case extract_response_attributes(response) do
        {:ok, typology_id, payload} ->
          unit_process_multi(%{
            building_id: building_id,
            typology_id: typology_id,
            payload: payload
          })

        error ->
          Logger.error("Error #{Kernel.inspect(error)} on unit response #{response})")
      end
    end)
  end

  defp extract_response_attributes({typology_id, {:ok, %{body: body}}}) do
    case Jason.decode(body) do
      {:ok, payload} -> {:ok, typology_id, payload}
      {:error, error} -> {:error, error}
    end
  end

  defp unit_process_multi(%{typology_id: typology_id} = params) do
    insert_key = "insert_units_for_typology_#{typology_id}"
    process_key = "process_units_for_typology_#{typology_id}"

    changeset =
      %UnitPayload{}
      |> UnitPayload.changeset(params)

    uuid = Changeset.get_field(changeset, :uuid)

    Multi.new()
    |> Multi.insert(insert_key, changeset)
    |> JobQueue.enqueue(process_key, %{
      "type" => "process_units",
      "uuid" => uuid
    })
  end

  def building_payload_synced?(external_id) do
    BuildingPayload
    |> where(external_id: ^external_id)
    |> Repo.exists?()
  end

  def get_units(building_id, typology_ids) do
    typology_ids
    |> Enum.reduce(%{}, fn typology_id, responses ->
      response = Client.get_units(building_id, typology_id)
      Map.put(responses, typology_id, response)
    end)
  end
end
