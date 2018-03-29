defmodule ReWeb.SitemapView do
  use ReWeb, :view

  def render("index.json", %{listings: listings}) do
    %{listings: render_many(listings, ReWeb.ListingView, "sitemap_listing.json")}
  end

end
