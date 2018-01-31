defmodule ReWeb.RelatedController do
  use ReWeb, :controller

  alias Re.Listings

  action_fallback(ReWeb.FallbackController)

  def index(conn, %{"listing_id" => id}) do
    with {:ok, listing} <- Listings.get(id),
         {:ok, listing} <- Listings.related(listing) do
      render(conn, ReWeb.ListingView, "index.json", listings: listing)
    end
  end
end
