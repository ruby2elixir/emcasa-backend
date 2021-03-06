defmodule ReIntegrations.Salesforce.Client do
  @moduledoc """
  Client to handle requests to an emcasa/salesforce api
  """
  require Mockery.Macro

  @api_key Application.get_env(:re_integrations, :salesforce_api_key, "")
  @api_url Application.get_env(:re_integrations, :salesforce_url, "")

  @api_headers [{"Authorization", @api_key}, {"Content-Type", "application/json"}]

  def get(id, :Account), do: get("/api/v1/Account/" <> id)
  def get(id, :User), do: get("/api/v1/User/" <> id)

  def insert_event(payload), do: post(payload, "/api/v1/Event")

  def update_opportunity(id, payload), do: patch(payload, "/api/v1/Opportunity/" <> id)

  def query(soql),
    do: post(%{soql: soql}, "/api/v1/query")

  defp build_uri(path), do: URI.parse(@api_url <> path)

  defp post(body, path),
    do: path |> build_uri |> http_client().post(Jason.encode!(body), @api_headers)

  defp patch(body, path),
    do: path |> build_uri |> http_client().patch(Jason.encode!(body), @api_headers)

  defp get(path),
    do: path |> build_uri |> http_client().get(@api_headers)

  defp http_client, do: Mockery.Macro.mockable(HTTPoison)
end
