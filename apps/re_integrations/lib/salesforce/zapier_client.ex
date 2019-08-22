defmodule ReIntegrations.Salesforce.ZapierClient do
  @moduledoc """
  Client to send reports to Slack through Zapier.
  """

  alias Re.{
    Calendars
  }

  alias ReIntegrations.Routific

  @url Application.get_env(:re_integrations, :zapier_schedule_visits_url, "")
  @http_client Application.get_env(:re_integrations, :http, HTTPoison)

  def post(%{body: _} = payload),
    do: @url |> URI.parse() |> @http_client.post(Jason.encode!(payload), [])
end
