defmodule ReIntegrations.Routific.Client do
  @moduledoc """
  Client to handle vehicle routing through routific.
  """

  alias ReIntegrations.{
    Routific,
    Routific.Payload
  }

  @api_key Application.get_env(:re_integrations, :routific_api_key, "")
  @api_url Application.get_env(:re_integrations, :routific_url, "https://api.routific.com")
  @http_client Application.get_env(:re_integrations, :http, HTTPoison)

  @api_headers [{"Authorization", "Bearer #{@api_key}"}, {"Content-Type", "application/json"}]

  def start_job(visits) do
    with {:ok, %{body: body}} <- request_start_job(visits),
         {:ok, payload} <- Jason.decode(body) do
      {:ok, payload}
    end
  end

  defp request_start_job(visits) do
    visits
    |> Payload.Outbound.build()
    |> post("/v1/vrp-long")
  end

  def fetch_job(job_id) do
    with {:ok, %{body: body}} <- get("/jobs/" <> job_id),
         {:ok, payload} <- Jason.decode(body) do
      {:ok, Payload.Inbound.build(payload)}
    end
  end

  defp build_uri(path), do: URI.parse(@api_url <> path)

  defp post(body, path) when is_map(body),
    do: path |> build_uri |> @http_client.post(Poison.encode!(body), @api_headers)

  defp get(path),
    do: path |> build_uri |> @http_client.get(@api_headers)
end
