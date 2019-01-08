defmodule ReWeb.RelatedController do
  use ReWeb, :controller
  use ReWeb.GuardedController

  alias Re.{
    Listings,
    Listings.Related
  }

  action_fallback(ReWeb.FallbackController)

  def index(conn, %{"listing_id" => id} = params, user) do
    with {:ok, listing} <- Listings.get_preloaded(id),
         params <- Map.put(params, "current_user", user),
         results <- Related.get(listing, params) do
      render(
        conn,
        ReWeb.ListingView,
        "index.json",
        listings: results.listings,
        remaining_count: results.remaining_count
      )
    end
  end
end
