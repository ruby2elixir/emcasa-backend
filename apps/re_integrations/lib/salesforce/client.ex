defmodule ReIntegrations.Salesforce.Client do
  @moduledoc """
  Client to handle requests to an emcasa/salesforce api
  """

  @api_key Application.get_env(:re_integrations, :salesforce_api_key, "")
  @api_url Application.get_env(:re_integrations, :salesforce_url, "")
  @http_client Application.get_env(:re_integrations, :http, HTTPoison)

  @api_headers [{"Authorization", @api_key}, {"Content-Type", "application/json"}]

  def insert_event(payload),
    do: post(payload, "/api/v1/Event")

  def query(soql),
    do: post(%{soql: soql}, "/api/v1/query")

  defp build_uri(path), do: URI.parse(@api_url <> path)

  defp post(body, path),
    do: path |> build_uri |> @http_client.post(Jason.encode!(body), @api_headers)
end
