defmodule ReIntegrations.Salesforce.ZapierClient do
  @moduledoc """
  Client to send reports to Slack through Zapier.
  """
  require Mockery.Macro

  @url Application.get_env(:re_integrations, :zapier_schedule_visits_url, "")

  def post(%{body: _} = payload),
    do: @url |> URI.parse() |> http_client().post(Jason.encode!(payload), [])

  defp http_client, do: Mockery.Macro.mockable(HTTPoison)
end
