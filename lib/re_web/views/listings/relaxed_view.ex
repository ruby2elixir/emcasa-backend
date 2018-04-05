defmodule ReWeb.RelaxedView do
  use ReWeb, :view

  def render("index.json", %{listings: listings, filters: filters}) do
    %{listings: render_many(listings, ReWeb.ListingView, "listing.json"), filters: filters}
  end
end
