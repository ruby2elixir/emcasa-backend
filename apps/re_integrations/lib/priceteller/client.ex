defmodule ReIntegrations.PriceTeller.Client do
  @moduledoc """
  Module to wrap priceteller API logic
  """

  @http_client Application.get_env(:re_integrations, :http, HTTPoison)
  @url Application.get_env(:re_integrations, :priceteller_url, "")

  def post(params) do
    {:ok, payload} = Poison.encode(%{payload: params})

    @url
    |> URI.parse()
    |> @http_client.post(payload)
  end
end
