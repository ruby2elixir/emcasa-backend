defmodule ReWeb.RelatedController do
  use ReWeb, :controller
  use ReWeb.GuardedController

  alias Re.{
    Listings,
    Listings.Related
  }

  @partial_preload [
    :address
  ]

  action_fallback(ReWeb.FallbackController)

  def index(conn, %{"listing_id" => id} = params, user) do
    with {:ok, listing} <- Listings.get_partial_preloaded(id, @partial_preload),
         params <- Map.put(params, "current_user", user),
         results <- Related.get(listing, params) do
      conn
      |> put_view(ReWeb.ListingView)
      |> render(
        "index.json",
        listings: results.listings,
        remaining_count: results.remaining_count
      )
    end
  end
end
