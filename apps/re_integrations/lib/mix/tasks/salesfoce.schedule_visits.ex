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

  def run(args) do
    start()
    date = get_date(args)
    Mix.shell().info("Scheduling visits for #{date}.")
    Salesforce.schedule_visits(date: date)
    Mix.shell().info("Routific job enqueued for monitoring.")
  end

  defp start do
    Enum.each(@start_apps, &Application.ensure_all_started/1)
    Enum.each(@repos, & &1.start_link(pool_size: 1))
  end

  defp tz_offset, do: @timezone |> Timex.timezone(Timex.now()) |> Timex.Timezone.total_offset()

  defp get_date([date_string | _args]) do
    with {:ok, date} <- Timex.parse(date_string, "{YYYY}-{0M}-{0D}") do
      date
      |> Timex.Timezone.convert(@timezone)
      |> Timex.shift(seconds: -tz_offset())
    end
  end

  defp get_date(_), do: @timezone |> Timex.now() |> Timex.shift(days: 1)
end
