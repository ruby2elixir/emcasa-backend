defmodule ReIntegrations.Routific.JobQueue do
  @moduledoc """
  Module for processing jobs related with routific payloads.
  """

  use EctoJob.JobQueue, table_name: "routific_jobs", schema_prefix: "re_integrations"

  alias Ecto.Multi

  alias ReIntegrations.{
    Repo,
    Routific
  }

  def perform(%Multi{} = multi, %{"type" => "monitor_routific_job", "job_id" => id}) do
    multi
    |> Multi.run(:get_job_status, fn _repo, _changes ->
      Routific.get_job_status(id)
    end)
    |> Repo.transaction()
  end
end
