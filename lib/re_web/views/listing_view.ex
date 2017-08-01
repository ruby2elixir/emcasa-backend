defmodule ReWeb.ListingView do
  use Re.Web, :view

  def render("index.json", %{listings: listings}) do
    %{data: render_many(listings, ReWeb.ListingView, "listing.json")}
  end

  def render("show.json", %{listing: listing}) do
    %{data: render_one(listing, ReWeb.ListingView, "listing.json")}
  end

  def render("listing.json", %{listing: listing}) do
    %{id: listing.id,
      description: listing.description,
      name: listing.name}
  end
end
