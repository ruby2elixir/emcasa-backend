defmodule ReIntegrations.Importers.Orulo.FetchJobQueue do
  @moduledoc """
  Module for processing jobs related with orulo entitiens payloads.
  """
  use EctoJob.JobQueue, table_name: "orulo_fetch_jobs"

  require Ecto.Query
  require Logger

  alias ReIntegrations.{
    Importers.Orulo.Building,
    Repo
  }

  alias Ecto.Multi

  def perform(%Multi{} = multi, %{"type" => "import_development_from_orulo", "external_id" => id}) do
    case ReIntegrations.Importers.Importer.get_building_from_orulo(id) do
      {:ok, payload} ->
        Building.changeset(%Building{}, %{external_id: id, payload: payload})
        |> Repo.insert()

      {:error, error} ->
        Logger.error(error)
    end
  end
end
