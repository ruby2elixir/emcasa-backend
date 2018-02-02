defmodule ReWeb.RelatedController do
  use ReWeb, :controller

  alias Re.{
    Listings,
    Listings.Related
  }

  action_fallback(ReWeb.FallbackController)

  def index(conn, %{"listing_id" => id} = params) do
    with {:ok, listing} <- Listings.get(id),
         {:ok, limit} <- get_limit(params),
         {:ok, listings} <- Related.get(listing, limit) do
      render(conn, ReWeb.ListingView, "index.json", listings: listings)
    end
  end

  defp get_limit(%{"limit" => limit}) do
    case Integer.parse(limit) do
      {limit, ""} -> {:ok, limit}
      _ -> {:error, :bad_request}
    end
  end

  defp get_limit(_), do: {:ok, :no_limit}
end
