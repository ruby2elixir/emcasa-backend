defmodule ReWeb.RelaxedController do
  use ReWeb, :controller

  alias Re.Listings.Relaxed

  action_fallback(ReWeb.FallbackController)

  def index(conn, params) do
    results = Relaxed.get(params)

    render(
      conn,
      "index.json",
      listings: results.listings,
      filters: results.filters,
      remaining_count: results.remaining_count
    )
  end
end
