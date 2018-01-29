defmodule ReWeb.FeaturedController do
  use ReWeb, :controller

  alias Re.Listings

  action_fallback(ReWeb.FallbackController)

  def index(conn, _params) do
    render(conn, ReWeb.ListingView, "featured.json", listings: Listings.featured())
  end
end
