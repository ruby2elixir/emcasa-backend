defmodule ReWeb.RelaxedView do
  use ReWeb, :view

  def render("index.json", %{
        listings: listings,
        filters: filters,
        remaining_count: remaining_count
      }) do
    %{
      listings: render_many(listings, ReWeb.ListingView, "listing.json"),
      filters: filters,
      remaining_count: remaining_count
    }
  end
end
