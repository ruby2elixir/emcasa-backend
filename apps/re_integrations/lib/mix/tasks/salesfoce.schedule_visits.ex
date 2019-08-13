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

  @start_apps [:timex, :postgrex, :ecto, :ecto_sql]
  @repos [Re.Repo, ReIntegrations.Repo]
  @timezone Application.get_env(:re_integrations, :timezone, "Etc/UTC")

  def run(_) do
    start()
    date = @timezone |> Timex.now() |> Timex.shift(days: 1)
    Mix.shell().info("Scheduling visits for #{date}.")
    Salesforce.schedule_visits(date: date)
    Mix.shell().info("Routific job enqueued for monitoring.")
  end

  defp start do
    Enum.each(@start_apps, &Application.ensure_all_started/1)
    Enum.each(@repos, & &1.start_link(pool_size: 1))
  end
end
