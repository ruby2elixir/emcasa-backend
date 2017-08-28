defmodule ReWeb.ListingView do
  use ReWeb, :view

  def render("index.json", %{listings: listings}) do
    %{data: render_many(listings, ReWeb.ListingView, "listing.json")}
  end

  def render("show.json", %{listing: listing}) do
    %{data: render_one(listing, ReWeb.ListingView, "listing.json")}
  end

  def render("listing.json", %{listing: listing}) do
    %{id: listing.id,
      name: listing.name,
      description: listing.description,
      floor: listing.floor,
      price: listing.price,
      area: listing.area,
      rooms: listing.rooms,
      bathrooms: listing.bathrooms,
      garage_spots: listing.garage_spots,
      address: %{
        street: listing.address.street,
        neighborhood: listing.address.neighborhood,
        city: listing.address.city,
        state: listing.address.state,
        postal_code: listing.address.postal_code
      }
    }
  end
end
