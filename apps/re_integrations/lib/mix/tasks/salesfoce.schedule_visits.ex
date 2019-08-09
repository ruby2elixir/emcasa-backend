defmodule Mix.Tasks.ReIntegrations.Salesforce.ScheduleVisits do
  @moduledoc """
  Schedule visits.
  """
  use Mix.Task

  require Logger

  alias ReIntegrations.{
    Salesforce
  }

  @shortdoc "Schedule visits"

  def run(_) do
    Mix.Task.run("app.start")
    Salesforce.schedule_visits(date: Timex.now() |> Timex.shift(days: 1))
    Mix.shell().info("Monitoring routific job.")
  end
end
