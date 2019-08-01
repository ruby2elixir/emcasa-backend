defmodule ReIntegrations.Salesforce.JobQueue do
  @moduledoc """
  Module for processing jobs related with emcasa/salesforce's api.
  """

  use EctoJob.JobQueue, table_name: "salesforce_jobs", schema_prefix: "re_integrations"

  require Logger

  alias Ecto.Multi

  alias ReIntegrations.{
    Repo,
    Salesforce
  }

  def perform(%Multi{} = multi, %{"type" => "insert_event", "event" => event}) do
    multi
    |> Multi.run(:insert_event, fn _repo, _changes ->
      Salesforce.insert_event(event)
    end)
    |> Repo.transaction()
  end
end
