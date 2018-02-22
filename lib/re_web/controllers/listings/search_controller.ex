defmodule ReWeb.SearchController do
  use ReWeb, :controller

  alias Re.Listings

  action_fallback(ReWeb.FallbackController)

  def index(conn, _params) do
    page = Listings.paginated()

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
