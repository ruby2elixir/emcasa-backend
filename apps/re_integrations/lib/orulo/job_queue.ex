defmodule ReIntegrations.Orulo.JobQueue do
  @moduledoc """
  Module for processing jobs related with orulo entitiens payloads.
  """
  use EctoJob.JobQueue, table_name: "orulo_jobs", schema_prefix: "re_integrations"

  require Ecto.Query
  require Logger

  alias ReIntegrations.{
    Orulo,
    Orulo.Client
  }

  alias Ecto.Multi

  def perform(%Multi{} = multi, %{"type" => "import_development_from_orulo", "external_id" => id}) do
    case Client.get_building(id) do
      {:ok, payload} ->
        Orulo.multi_building_insert(multi, %{external_id: id, payload: payload})

      {:error, error} ->
        Logger.error(error)
    end
  end
end
