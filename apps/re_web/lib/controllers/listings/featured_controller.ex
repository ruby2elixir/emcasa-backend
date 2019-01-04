defmodule ReWeb.FeaturedController do
  use ReWeb, :controller

  alias Re.Listings.Featured

  action_fallback(ReWeb.FallbackController)

  def index(conn, _params) do
    conn
    |> put_view(ReWeb.ListingView)
    |> render("featured.json", listings: Featured.get())
  end
end
