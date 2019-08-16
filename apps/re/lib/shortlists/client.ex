defmodule Re.Shortlists.Client do
  @moduledoc """
  Shortlists service client
  """
  require Mockery.Macro

  @url Application.get_env(:re, :shortlist_service_url, "")

  def get_listings_uuids(params) do
    @url
    |> URI.parse()
    |> http_client().get(params)
  end

  defp http_client, do: Mockery.Macro.mockable(HTTPoison)
end
