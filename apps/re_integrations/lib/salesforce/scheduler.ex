defmodule ReIntegrations.Salesforce.Scheduler do
  @moduledoc false
  alias ReIntegrations.Salesforce

  use Quantum.Scheduler,
    otp_app: :re_integrations

  @timezone Application.get_env(:re_integrations, :timezone, "Etc/UTC")

  def schedule_daily_visits(nil), do: @timezone |> Timex.now() |> schedule_daily_visits()

  def schedule_daily_visits(%DateTime{} = today) do
    today
    |> Timex.weekday()
    |> case do
      7 ->
        []

      6 ->
        []

      5 ->
        [Timex.shift(today, days: 1), Timex.shift(today, days: 3)]

      _ ->
        [Timex.shift(today, days: 1)]
    end
    |> Enum.map(&Salesforce.schedule_visits(date: &1))
  end
end
