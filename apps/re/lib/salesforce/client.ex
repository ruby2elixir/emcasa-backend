defmodule Re.Salesforce.Client do
  @moduledoc """
  Client to handle requests to an emcasa/salesforce api
  """

  @api_key Application.get_env(:re_integrations, :salesforce_api_key, "")
  @api_url Application.get_env(:re_integrations, :salesforce_url, "")
  @http_client Application.get_env(:re, :http, HTTPoison)

  @api_headers [{"Authorization", @api_key}, {"Content-Type", "application/json"}]

  def insert_lead(payload), do: post(payload, "/api/v1/Lead")

  def update_lead(payload, id), do: patch(payload, "/api/v1/Lead/" <> id)

  def get(id, :Opportunity), do: get("/api/v1/Opportunity/" <> id)

  defp build_uri(path), do: URI.parse(@api_url <> path)

  defp post(body, path),
    do: path |> build_uri |> @http_client.post(Jason.encode!(body), @api_headers)

  defp patch(body, path),
    do: path |> build_uri |> @http_client.patch(Jason.encode!(body), @api_headers)

  defp get(path),
    do: path |> build_uri |> @http_client.get(@api_headers)

  def query(soql), do: post(%{soql: soql}, "/api/v1/query")
end
