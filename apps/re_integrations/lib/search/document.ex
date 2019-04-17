defimpl Elasticsearch.Document, for: Re.Listing do
  def id(listing), do: listing.id

  def routing(listing), do: listing.id

  def encode(listing) do
    %{
      type: listing.type,
      price: listing.price,
      rooms: listing.rooms,
      area: listing.area,
      garage_spots: listing.garage_spots,
      neighborhood_slug: listing.address.neighborhood_slug,
      inserted_at: listing.inserted_at,
      updated_at: listing.updated_at
    }
  end
end
