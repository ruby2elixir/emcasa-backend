defmodule ReWeb.RelaxedController do
  use ReWeb, :controller

  alias Re.Listings.Relaxed

  action_fallback(ReWeb.FallbackController)

  def index(conn, params) do
    result = Relaxed.get(params)

    render(conn, "index.json", listings: result.listings, filters: result.filters)
  end
end
