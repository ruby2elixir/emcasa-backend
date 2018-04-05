defmodule ReWeb.RelatedController do
  use ReWeb, :controller

  alias Re.{
    Listings,
    Listings.Related
  }

  action_fallback(ReWeb.FallbackController)

  def index(conn, %{"listing_id" => id} = params) do
    with {:ok, listing} <- Listings.get_preloaded(id),
         listings <- Related.get(listing, params) do
      render(conn, ReWeb.ListingView, "index.json", listings: listings)
    end
  end
end
