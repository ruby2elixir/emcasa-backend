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

  defp build_uri(path), do: URI.parse(@api_url <> path)

  defp post(body, path),
    do: path |> build_uri |> @http_client.post(Jason.encode!(body), @api_headers)

  defp patch(body, path),
    do: path |> build_uri |> @http_client.patch(Jason.encode!(body), @api_headers)
end
