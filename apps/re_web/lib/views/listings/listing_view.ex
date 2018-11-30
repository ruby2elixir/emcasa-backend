defmodule ReWeb.ListingView do
  use ReWeb, :view

  def render("index.json", %{listings: listings, remaining_count: remaining_count}) do
    %{
      listings: render_many(listings, ReWeb.ListingView, "listing.json"),
      remaining_count: remaining_count
    }
  end

  def render("featured.json", %{listings: listings}) do
    %{listings: render_many(listings, ReWeb.ListingView, "listing.json")}
  end

  def render("edit.json", %{listing: listing}) do
    %{listing: render_one(listing, ReWeb.ListingView, "listing_edit.json")}
  end

  def render("show.json", %{listing: listing}) do
    %{listing: render_one(listing, ReWeb.ListingView, "listing.json")}
  end

  def render("create.json", %{listing: listing}) do
    %{listing: render_one(listing, ReWeb.ListingView, "listing_id.json")}
  end

  def render("listing.json", %{listing: listing}) do
    %{
      id: listing.id,
      type: listing.type,
      description: listing.description,
      floor: listing.floor,
      price: listing.price,
      property_tax: listing.property_tax,
      maintenance_fee: listing.maintenance_fee,
      area: listing.area,
      rooms: listing.rooms,
      bathrooms: listing.bathrooms,
      restrooms: listing.restrooms,
      garage_spots: listing.garage_spots,
      garage_type: listing.garage_type,
      matterport_code: listing.matterport_code,
      suites: listing.suites,
      dependencies: listing.dependencies,
      balconies: listing.balconies,
      has_elevator: listing.has_elevator,
      is_exclusive: listing.is_exclusive,
      is_release: listing.is_release,
      is_active: listing.status == "active",
      inserted_at: listing.inserted_at,
      address: %{
        street: listing.address.street,
        street_slug: listing.address.street_slug,
        neighborhood: listing.address.neighborhood,
        neighborhood_slug: listing.address.neighborhood_slug,
        city: listing.address.city,
        city_slug: listing.address.city_slug,
        state: listing.address.state,
        state_slug: listing.address.state_slug,
        postal_code: listing.address.postal_code,
        lat: listing.address.lat,
        lng: listing.address.lng
      },
      user_id: listing.user_id,
      images: render_many(listing.images, ReWeb.ImageView, "image.json")
    }
  end

  def render("listing_edit.json", %{listing: listing}) do
    %{
      id: listing.id,
      type: listing.type,
      complement: listing.complement,
      description: listing.description,
      floor: listing.floor,
      price: listing.price,
      property_tax: listing.property_tax,
      maintenance_fee: listing.maintenance_fee,
      area: listing.area,
      rooms: listing.rooms,
      bathrooms: listing.bathrooms,
      restrooms: listing.restrooms,
      garage_spots: listing.garage_spots,
      garage_type: listing.garage_type,
      score: listing.score,
      matterport_code: listing.matterport_code,
      suites: listing.suites,
      dependencies: listing.dependencies,
      balconies: listing.balconies,
      has_elevator: listing.has_elevator,
      is_exclusive: listing.is_exclusive,
      is_release: listing.is_release,
      is_active: listing.status == "active",
      inserted_at: listing.inserted_at,
      address: %{
        street: listing.address.street,
        street_slug: listing.address.street_slug,
        street_number: listing.address.street_number,
        neighborhood: listing.address.neighborhood,
        neighborhood_slug: listing.address.neighborhood_slug,
        city: listing.address.city,
        city_slug: listing.address.city_slug,
        state: listing.address.state,
        state_slug: listing.address.state_slug,
        postal_code: listing.address.postal_code,
        lat: listing.address.lat,
        lng: listing.address.lng
      },
      images: render_many(listing.images, ReWeb.ImageView, "image.json")
    }
  end

  def render("listing_id.json", %{listing: listing}) do
    %{id: listing.id}
  end

  def render("sitemap_listing.json", %{listing: listing}) do
    %{
      id: listing.id,
      updated_at: listing.updated_at,
      address: %{
        street: listing.address.street,
        neighborhood: listing.address.neighborhood,
        city: listing.address.city,
        state: listing.address.state
      }
    }
  end

  def render("coordinates.json", %{listings: listings}) do
    %{listings: render_many(listings, ReWeb.ListingView, "coordinate.json")}
  end

  def render("coordinate.json", %{listing: listing}) do
    %{
      id: listing.id,
      address: %{
        lat: listing.address.lat,
        lng: listing.address.lng
      }
    }
  end
end
