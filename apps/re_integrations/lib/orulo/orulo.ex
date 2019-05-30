defmodule ReIntegrations.Orulo do
  @moduledoc """
  Context module to use importers.
  """
  alias ReIntegrations.{
    Orulo.Building,
    Orulo.JobQueue,
    Repo
  }

  alias Ecto.{
    Changeset,
    Multi
  }

  def get_building_payload(id) do
    %{"type" => "import_development_from_orulo", "external_id" => id}
    |> JobQueue.new()
    |> Repo.insert()
  end

  def multi_building_insert(multi, params) do
    changeset =
      %Building{}
      |> Building.changeset(params)

    uuid = Changeset.get_field(changeset, :uuid)

    Multi.insert(multi, :building, changeset)
    |> JobQueue.enqueue(:building_parse, %{
      "type" => "parse_building_into_development",
      "uuid" => uuid
    })
    |> Repo.transaction()
  end
end
