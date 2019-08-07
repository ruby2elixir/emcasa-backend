defmodule ReIntegrations.Salesforce.JobQueue do
  @moduledoc """
  Module for processing jobs related with emcasa/salesforce's api.
  """

  use EctoJob.JobQueue, table_name: "salesforce_jobs", schema_prefix: "re_integrations"

  require Logger

  alias Ecto.Multi

  alias ReIntegrations.{
    Repo,
    Routific,
    Salesforce
  }

  def perform(%Multi{} = multi, %{"type" => "monitor_routific_job", "job_id" => id}) do
    multi
    |> Multi.run(:get_job_status, fn _repo, _changes ->
      with {:ok, payload} <- Routific.get_job_status(id) do
        {:ok, payload}
      else
        {:error, error} -> {:error, error}
        {status, _data} -> {:error, status}
      end
    end)
    |> Multi.merge(fn %{get_job_status: payload} ->
      Enum.reduce(payload.solution, Ecto.Multi.new(), fn route, multi ->
        enqueue_insert_routific_events(multi, route, payload)
      end)
    end)
    |> Repo.transaction()
  end

  def perform(%Multi{} = multi, %{
        "type" => "insert_event",
        "opportunity_id" => opportunity_id,
        "event" => event
      }) do
    multi
    |> Multi.run(:insert_event, fn _repo, _changes -> Salesforce.insert_event(event) end)
    |> __MODULE__.enqueue(:update_opportunity, %{
      "type" => "update_opportunity",
      "id" => opportunity_id,
      "opportunity" => %{stage: :visit_scheduled}
    })
    |> Repo.transaction()
  end

  def perform(%Multi{} = multi, %{
        "type" => "update_opportunity",
        "id" => id,
        "opportunity" => payload
      }) do
    multi
    |> Multi.run(:update_opportunity, fn _repo, _changes ->
      Salesforce.update_opportunity(id, payload)
    end)
    |> Repo.transaction()
  end

  defp enqueue_insert_routific_events(multi, {calendar_uuid, [_depot | events]}, payload),
    do: Salesforce.enqueue_insert_routific_events(multi, events, calendar_uuid, payload)
end
