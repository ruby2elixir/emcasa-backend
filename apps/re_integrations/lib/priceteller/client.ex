defmodule ReIntegrations.PriceTeller.Client do
  @moduledoc """
  Module to wrap priceteller API logic
  """

  @http_client Application.get_env(:re_integrations, :http, HTTPoison)
  @url Application.get_env(:re_integrations, :priceteller_url, "")
  @token Application.get_env(:re_integrations, :priceteller_token, "")

  def post(params) do
    {:ok, payload} = Poison.encode(%{payload: params})

    headers = [
      {"Content-Type", "application/json"},
      {"X-Api-Key", @token}
    ]

    @url
    |> URI.parse()
    |> @http_client.post(payload, headers)
  end
end
