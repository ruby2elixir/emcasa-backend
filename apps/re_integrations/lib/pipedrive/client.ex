defmodule ReIntegrations.Pipedrive.Client do
  @moduledoc """
  Module to wrap pipedrive.com API logic
  """

  @http_client Application.get_env(:re_integrations, :http_client, HTTPoison)
  @url Application.get_env(:re_integrations, :pipedrive_url, "")
  @token Application.get_env(:re_integrations, :pipedrive_token, "")
  @headers [{"Content-Type", "application/json"}]

  def get(type \\ "", params \\ %{})

  def get(type, params) do
    params = Map.merge(params, %{api_token: @token})

    @url
    |> build_uri(type, params)
    |> @http_client.get(@headers)
  end

  def build_uri(url, type, params) do
    url
    |> URI.parse()
    |> URI.merge(type)
    |> Map.put(:port, 443)
    |> Map.put(:query, URI.encode_query(params))
  end
end
