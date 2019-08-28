defmodule ReIntegrations.Salesforce.Scheduler do
  @moduledoc false
  alias ReIntegrations.Salesforce

  use Quantum.Scheduler,
    otp_app: :re_integrations

  @timezone Application.get_env(:re_integrations, :timezone, "Etc/UTC")

  def schedule_daily_visits(), do: @timezone |> Timex.now() |> schedule_daily_visits()

  def schedule_daily_visits(%DateTime{} = today) do
    today
    |> Timex.weekday()
    |> dates_to_schedule_on_weekday()
    |> Enum.map(&Salesforce.schedule_visits(date: Timex.shift(today, &1)))
  end

  defp dates_to_schedule_on_weekday(7), do: []
  defp dates_to_schedule_on_weekday(6), do: []
  defp dates_to_schedule_on_weekday(5), do: [[days: 1], [days: 3]]
  defp dates_to_schedule_on_weekday(_), do: [[days: 1]]
end
