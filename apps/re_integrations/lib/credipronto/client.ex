defmodule ReIntegrations.Credipronto.Client do
  @moduledoc """
  Module to wrap credipronto API logic
  """

  @http_client Application.get_env(:re, :http_client, HTTPoison)
  @url Application.get_env(:re_integrations, :credipronto_simulador_url, "")
  @account_id Application.get_env(:re_integrations, :credipronto_account_id, "")

  def get(params \\ @params) do
    params = Map.merge(params, %{account_id: @account_id})

    @url
    |> build_uri(params)
    |> @http_client.get([], follow_redirect: true)
  end

  def build_uri(url, params) do
    url
    |> URI.parse()
    |> Map.put(:query, URI.encode_query(params))
  end
end
