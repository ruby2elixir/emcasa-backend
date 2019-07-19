defmodule ReIntegrations.Routific.Client do
  @moduledoc """
  Client to handle vehicle routing through routific.
  """

  alias ReIntegrations.{
    Routific.Payload
  }

  @api_key Application.get_env(:re_integrations, :routific_api_key, "")
  @api_url Application.get_env(:re_integrations, :routific_url, "")
  @http_client Application.get_env(:re_integrations, :http, HTTPoison)

  @api_headers [{"Authorization", "Bearer #{@api_key}"}, {"Content-Type", "application/json"}]

  def start_job(%Payload.Outbound{} = payload),
    do: payload |> post("/v1/vrp-long")

  def fetch_job(job_id), do: get("/jobs/" <> job_id)

  defp build_uri(path), do: URI.parse(@api_url <> path)

  defp post(body, path),
    do: path |> build_uri |> @http_client.post(Poison.encode!(body), @api_headers)

  defp get(path),
    do: path |> build_uri |> @http_client.get(@api_headers)
end
