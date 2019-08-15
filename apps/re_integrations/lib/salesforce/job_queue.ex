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
    Salesforce,
    Salesforce.Mapper
  }

  def perform(%Multi{} = multi, %{"type" => "monitor_routific_job", "job_id" => id}) do
    multi
    |> Multi.run(:get_job_status, fn _repo, _changes -> get_routific_job(id) end)
    |> Multi.merge(fn %{get_job_status: payload} ->
      enqueue_routific_insert_events(Ecto.Multi.new(), payload)
    end)
    |> Multi.merge(fn %{get_job_status: payload} ->
      enqueue_routific_update_unserved(Ecto.Multi.new(), payload)
    end)
    |> Repo.transaction()
    |> handle_error()
  end

  def perform(%Multi{} = multi, %{
        "type" => "insert_event",
        "opportunity_id" => opportunity_id,
        "route_id" => route_id,
        "event" => event
      }) do
    multi
    |> Multi.run(:insert_event, fn _repo, _changes -> Salesforce.insert_event(event) end)
    |> __MODULE__.enqueue(:update_opportunity, %{
      "type" => "update_opportunity",
      "id" => opportunity_id,
      "opportunity" => %{stage: :visit_scheduled, route_unserved_reason: "", route_id: route_id}
    })
    |> Repo.transaction()
    |> handle_error()
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
    |> handle_error()
  end

  defp get_routific_job(job_id) do
    with {:ok, payload} <- Routific.get_job_status(job_id) do
      {:ok, payload}
    else
      {:error, error} -> {:error, error}
      {status, _data} -> {:error, status}
    end
  end

  defp enqueue_routific_insert_events(multi, payload),
    do:
      Enum.reduce(payload.solution, multi, fn route, multi ->
        enqueue_calendar_insert_events(multi, route, payload)
      end)

  defp enqueue_calendar_insert_events(multi, {calendar_uuid, [_depot | events]}, payload),
    do:
      events
      |> Enum.filter(&(not Map.get(&1, :break)))
      |> Enum.reduce(multi, fn event, multi ->
        __MODULE__.enqueue(multi, "schedule_#{event.id}", %{
          "type" => "insert_event",
          "event" => Mapper.Routific.build_event(event, calendar_uuid, payload),
          "route_id" => payload.id,
          "opportunity_id" => event.id
        })
      end)

  defp enqueue_routific_update_unserved(multi, payload),
    do:
      Enum.reduce(payload.unserved, multi, fn {opportunity_id, reason}, multi ->
        __MODULE__.enqueue(multi, "update_#{opportunity_id}", %{
          "type" => "update_opportunity",
          "id" => opportunity_id,
          "opportunity" => %{
            route_unserved_reason: reason,
            route_id: payload.id
          }
        })
      end)

  defp handle_error({:ok, result}), do: {:ok, result}

  defp handle_error({:error, :get_job_status, :pending, _changes} = result),
    do: result

  defp handle_error(error) do
    Sentry.capture_message("error when performing Salesforce.JobQueue",
      extra: %{error: error}
    )

    raise "Error when performing Salesforce.JobQueue"
  end
end
