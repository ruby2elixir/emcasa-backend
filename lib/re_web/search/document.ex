defimpl Elasticsearch.Document, for: Re.Listing do
  def id(listing), do: listing.id

  def encode(listing) do
    %{
      everything: """
        #{listing.type}
        #{listing.description}
        #{listing.floor}
        #{listing.price && "#{listing.price} valor"}
        #{listing.property_tax && "#{listing.property_tax} IPTU"}
        #{listing.maintenance_fee && "#{listing.maintenance_fee} condominio"}
        #{listing.area}
        #{map_price(listing)}
        #{map_property_tax(listing)}
        #{map_maintenance_fee(listing)}
        #{listing.is_exclusive && "exclusivo"}
        #{listing.is_release && "lançamento"}
        #{listing.matterport_code}
      """,
      rooms: map_rooms(listing),
      bathrooms: map_bathrooms(listing),
      garage_spots: map_garage_spots(listing),
      restrooms: map_restrooms(listing),
      suites: map_suites(listing),
      dependencies: map_dependencies(listing),
      balconies: map_balconies(listing),
      address: map_address(listing),
      inserted_at: listing.inserted_at,
      location: %{
        lat: listing.address.lat,
        lon: listing.address.lng
      }
    }
  end

  defp map_address(%{
         complement: complement,
         address: %{
           street: street,
           street_number: street_number,
           neighborhood: neighborhood,
           city: city,
           state: state,
           postal_code: postal_code
         }
       }) do
    "#{street} #{street_number} #{neighborhood} #{city} #{state} #{postal_code} #{complement}"
  end

  defp map_price(%{price: price}), do: price && "#{price} valor"
  defp map_property_tax(%{property_tax: property_tax}), do: property_tax && "#{property_tax} IPTU"

  defp map_maintenance_fee(%{maintenance_fee: maintenance_fee}),
    do: maintenance_fee && "#{maintenance_fee} condominio"

  defp map_rooms(%{rooms: rooms}), do: if_not_zero(rooms, "quarto", "quartos")
  defp map_bathrooms(%{bathrooms: bathrooms}), do: if_not_zero(bathrooms, "banheiro", "banheiros")

  defp map_garage_spots(%{garage_spots: garage_spots}),
    do: if_not_zero(garage_spots, "garagem", "garagens")

  defp map_restrooms(%{restrooms: restrooms}), do: if_not_zero(restrooms, "lavabo", "lavabos")
  defp map_suites(%{suites: suites}), do: if_not_zero(suites, "suíte", "suítes")

  defp map_dependencies(%{dependencies: dependencies}),
    do: if_not_zero(dependencies, "dependência", "dependências")

  defp map_balconies(%{balconies: balconies}), do: if_not_zero(balconies, "varanda", "varandas")

  defp if_not_zero(0, _, _), do: ""
  defp if_not_zero(1, singular, _plural), do: "1 #{singular}"
  defp if_not_zero(num, _singular, plural), do: "#{num} #{plural}"
end
