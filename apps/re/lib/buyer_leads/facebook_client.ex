defmodule Re.BuyerLeads.FacebookClient do
  require Mockery.Macro

  @token Application.get_env(:re, :facebook_access_token, "")

  def get_lead(lead_id) do
    lead_id
    |> build_url()
    |> http_client().get()
  end

  defp build_url(lead_id) do
    "https://graph.facebook.com/v3.3/"
    |> URI.parse()
    |> URI.merge("/#{lead_id}/")
    |> Map.put(:query, URI.encode_query(%{access_token: @token}))
  end

  defp http_client(), do: Mockery.Macro.mockable(HTTPoison)
end
