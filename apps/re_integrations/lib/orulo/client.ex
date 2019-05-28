defmodule ReIntegrations.Orulo.Client do
  @moduledoc """
  Module to wripe orulo API logic
  """

  @http_client Application.get_env(:re_integrations, :http_client, HTTPoison)
  @base_url Application.get_env(:re_integrations, :orulo_url, "")
  @client_token Application.get_env(:re_integrations, :orulo_client_token, "")

  @client_headers [{"Authorization", "Bearer #{@client_token}"}]

  def get_building(id) when is_integer(id) do
    @base_url
    |> build_uri("/buildings/#{id}")
    |> @http_client.get(@client_headers)
  end

  def build_uri(url, type) do
    url
    |> URI.parse()
    |> URI.merge(type)
  end
end
