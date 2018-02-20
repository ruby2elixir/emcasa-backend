defmodule ReWeb.RelaxedController do
  use ReWeb, :controller

  alias Re.Listings.Relaxed

  action_fallback(ReWeb.FallbackController)

  def index(conn, params) do
    page = Relaxed.get(params)

    render(
      conn,
      "index.json",
      listings: page.entries,
      filters: page.filters,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries
    )
  end
end
