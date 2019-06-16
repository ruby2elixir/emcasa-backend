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

  def multi_building_payload_insert(multi, params) do
    changeset =
      %BuildingPayload{}
      |> BuildingPayload.changeset(params)

    uuid = Changeset.get_field(changeset, :uuid)

    multi
    |> Multi.insert(:building, changeset)
    |> JobQueue.enqueue(:building_parse, %{
      "type" => "parse_building_into_development",
      "uuid" => uuid
    })
    |> Repo.transaction()
  end

  def multi_images_payload_insert(multi, params) do
    changeset =
      %ImagePayload{}
      |> ImagePayload.changeset(params)

    uuid = Changeset.get_field(changeset, :uuid)

    multi
    |> Multi.insert(:insert_images_payload, changeset)
    |> JobQueue.enqueue(:parse_images_job, %{
      "type" => "parse_images_payloads_into_images",
      "uuid" => uuid
    })
    |> Repo.transaction()
  end

  def insert_typologies_payload(multi, params) do
    changeset =
      %TypologyPayload{}
      |> TypologyPayload.changeset(params)

    uuid = Changeset.get_field(changeset, :uuid)

    multi
    |> Multi.insert(:insert_typologies_payload, changeset)
    |> JobQueue.enqueue(:fetch_units, %{
      "type" => "fetch_units",
      "uuid" => uuid
    })
    |> Repo.transaction()
  end

  def bulk_insert_unit_payload_forking_multi(%Multi{} = multi, responses) do
    multies =
      Enum.map(responses, fn response ->
        #  {:ok, payload} <- Jason.decode(body),
        with {typology_id, {:ok, %{body: payload}}} <- response do
          insert_unit_payload(
            Multi.new(),
            %{
              building_id: "1",
              typology_id: Integer.to_string(typology_id),
              payload: payload
            }
          )
        else
          error -> Logger.error("Error on units request:  #{Kernel.inspect(error)}")
        end
      end)

    Enum.reduce(multies, multi, fn unit_multi, acc ->
      Multi.prepend(acc, unit_multi)
    end)
    |> ReIntegrations.Repo.transaction()
  end

  def insert_unit_payload(multi, %{typology_id: typology_id} = params) do
    insert_key = "insert_units_for_typology_#{typology_id}" |> String.to_atom()
    process_key = "process_units_for_typology_#{typology_id}" |> String.to_atom()

    changeset =
      %UnitPayload{}
      |> UnitPayload.changeset(params)

    uuid = Changeset.get_field(changeset, :uuid)

    multi
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
