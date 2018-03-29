defmodule ReWeb.ListingView do
  use ReWeb, :view

  def render("paginated_index.json", %{
        listings: listings,
        page_number: page_number,
        page_size: page_size,
        total_pages: total_pages,
        total_entries: total_entries
      }) do
    %{
      listings: render_many(listings, ReWeb.ListingView, "listing.json"),
      page_number: page_number,
      page_size: page_size,
      total_pages: total_pages,
      total_entries: total_entries
    }
  end

  def render("index.json", %{listings: listings}) do
    %{listings: render_many(listings, ReWeb.ListingView, "listing.json")}
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
      garage_spots: listing.garage_spots,
      matterport_code: listing.matterport_code,
      suites: listing.suites,
      dependencies: listing.dependencies,
      has_elevator: listing.has_elevator,
      is_exclusive: listing.is_exclusive,
      is_active: listing.is_active,
      address: %{
        street: listing.address.street,
        street_number: listing.address.street_number,
        neighborhood: listing.address.neighborhood,
        city: listing.address.city,
        state: listing.address.state,
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
      garage_spots: listing.garage_spots,
      score: listing.score,
      matterport_code: listing.matterport_code,
      suites: listing.suites,
      dependencies: listing.dependencies,
      has_elevator: listing.has_elevator,
      is_exclusive: listing.is_exclusive,
      is_active: listing.is_active,
      address: %{
        street: listing.address.street,
        street_number: listing.address.street_number,
        neighborhood: listing.address.neighborhood,
        city: listing.address.city,
        state: listing.address.state,
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
    %{id: listing.id, updated_at: listing.updated_at}
  end
end
