defimpl Elasticsearch.Document, for: Re.Listing do
  def id(listing), do: listing.id
  def encode(listing) do
    %{
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
      matterport_code: listing.matterport_code,
      suites: listing.suites,
      dependencies: listing.dependencies,
      balconies: listing.balconies,
      has_elevator: listing.has_elevator,
      is_exclusive: listing.is_exclusive,
      is_release: listing.is_release,
      inserted_at: listing.inserted_at,
      street: listing.address.street,
      street_number: listing.address.street_number,
      neighborhood: listing.address.neighborhood,
      city: listing.address.city,
      state: listing.address.state,
      postal_code: listing.address.postal_code,
      lat: listing.address.lat,
      lng: listing.address.lng
    }
  end
end
