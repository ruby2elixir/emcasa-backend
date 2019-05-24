defmodule ReIntegrations.Orulo.Client do
  @moduledoc """
  Module to wripe orulo API logic
  """

  @http_client Application.get_env(:re_integrations, :http_client, HTTPoison)
  @base_url Application.get_env(:re_integrations, :orulo_url, "")
  @client_token Application.get_env(:re_integrations, :orulo_client_token, "")

  @client_headers [{"Authorization", "Bearer #{@client_token}"}]

  def get_building(id) when is_integer(id) do
    url = "#{@base_url}buildings/#{id}"
    @http_client.get(url, @client_headers)
  end
end
