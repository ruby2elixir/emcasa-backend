defmodule ReIntegrations.Orulo do
  @moduledoc """
  Context module to use importers.
  """

  import Ecto.Query, only: [from: 2]

  alias ReIntegrations.{
    Orulo.BuildingPayload,
    Orulo.ImagePayload,
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

  def building_payload_synced?(external_id) do
    # credo:disable-for-lines:3
    (bp in BuildingPayload)
    |> from(where: bp.external_id == ^external_id)
    |> Repo.exists?()
  end
end
