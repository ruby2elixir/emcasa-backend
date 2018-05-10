defmodule ReWeb.Integrations.Pipedrive do
  @moduledoc """
  Module to wrap pipedrive.com API logic
  """

  @http_client Application.get_env(:re, :http_client, HTTPoison)
  @url Application.get_env(:re, :pipedrive_url, "")
  @token Application.get_env(:re, :pipedrive_token, "")
  @headers [{"Content-Type", "application/json"}]

  def get(type, params) do
    params = Map.merge(params, %{api_token: @token})

    @url
    |> build_uri(type, params)
    |> @http_client.get(@headers)
  end

  def build_uri(url, type, params) do
    %URI{
      host: url,
      path: type,
      port: 443,
      query: URI.encode_query(params)
    }
  end
end
