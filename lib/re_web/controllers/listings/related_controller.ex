defmodule ReWeb.RelatedController do
  use ReWeb, :controller

  alias Re.{
    Listings,
    Listings.Related
  }

  action_fallback(ReWeb.FallbackController)

  def index(conn, %{"listing_id" => id} = params) do
    with {:ok, listing} <- Listings.get_preloaded(id),
         page <- Related.get(listing, params) do
      render(
        conn,
        ReWeb.ListingView,
        "paginated_index.json",
        listings: page.entries,
        page_number: page.page_number,
        page_size: page.page_size,
        total_pages: page.total_pages,
        total_entries: page.total_entries
      )
    end
  end
end
