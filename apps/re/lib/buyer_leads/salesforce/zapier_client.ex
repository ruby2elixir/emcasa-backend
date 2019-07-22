defmodule Re.BuyerLeads.Salesforce.ZapierClient do
  @moduledoc """
  Module for zapier webhook trigger
  """
  require Mockery.Macro

  @url Application.get_env(:re, :zapier_create_salesforce_lead_url, "")

  def post(payload) do
    @url
    |> URI.parse()
    |> http_client().post(payload)
  end

  defp http_client, do: Mockery.Macro.mockable(HTTPoison)
end
