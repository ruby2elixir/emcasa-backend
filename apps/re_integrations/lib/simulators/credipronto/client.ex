defmodule ReIntegrations.Credipronto.Client do
  @moduledoc """
  Module to wrap credipronto API logic
  """
  require Mockery.Macro

  @url Application.get_env(:re_integrations, :credipronto_simulator_url, "")
  @account_id Application.get_env(:re_integrations, :credipronto_account_id, "")

  def get(params) do
    params = Map.merge(params, %{account_id: @account_id})

    @url
    |> build_uri(params)
    |> http_client().get([], follow_redirect: true)
  end

  def build_uri(url, params) do
    url
    |> URI.parse()
    |> Map.put(:query, URI.encode_query(params))
  end

  defp http_client, do: Mockery.Macro.mockable(HTTPoison)
end
