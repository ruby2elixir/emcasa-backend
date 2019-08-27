defmodule Re.Shortlists.Selekta do
  @moduledoc """
  Shortlists service client
  """

  alias Re.Shortlists.Salesforce.Opportunity

  require Mockery.Macro

  @url Application.get_env(:re, :selekta_url, "")

  def suggest_shortlist(opportunity) do
    with {:ok, params} <- create_params(opportunity),
         {:ok, listing_uuids} <- get_decode_shortlist(params) do
      {:ok, listing_uuids}
    else
      error -> error
    end
  end

  defp create_params(opportunity) do
    opportunity
    |> Opportunity.build()
    |> case do
      {:ok, params} -> {:ok, Map.put(%{}, :characteristcs, params)}
      error -> error
    end
  end

  defp get_decode_shortlist(params) do
    with {:ok, %{body: body}} <- get_listings_uuids(params) do
      Jason.decode(body)
    end
  end

  defp get_listings_uuids(params) do
    @url
    |> URI.parse()
    |> http_client().get(params)
  end

  defp http_client, do: Mockery.Macro.mockable(HTTPoison)
end
