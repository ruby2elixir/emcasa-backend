defmodule Re.Shortlists.Client do
  @moduledoc """
  Shortlists service client
  """
  @url Application.get_env(:re, :shortlist_service_url, "")

  def get_listings(params) do
    @url
    |> URI.parse()
    |> HTTPoison.get(params)
  end
end
