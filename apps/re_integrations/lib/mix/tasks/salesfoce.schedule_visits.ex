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

  @start_apps [
    :timex,
    :postgrex,
    :ecto,
    :ecto_sql
  ]
  @timezone Application.get_env(:re_integrations, :timezone, "Etc/UTC")

  def run(_) do
    Application.load(:re_integrations)
    Enum.each(@start_apps, &Application.ensure_all_started/1)
    Salesforce.schedule_visits(date: Timex.now(@timezone) |> Timex.shift(days: 1))
    Mix.shell().info("Routific job enqueued for monitoring.")
  end
end
