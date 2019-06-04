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
    with {:ok, %{body: body}} <- Client.get_building(id),
         {:ok, payload} <- Jason.decode(body),
         {:ok, _} <- Orulo.multi_building_insert(multi, %{external_id: id, payload: payload}) do
    else
      {:error, error} -> Logger.error(error)
      error -> Logger.error(error)
    end
  end

  def perform(%Multi{} = multi, %{"type" => "parse_building_into_development", "uuid" => uuid}) do
    Orulo.insert_development_from_building_payload(multi, uuid)
  end
end
