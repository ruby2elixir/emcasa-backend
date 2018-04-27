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
        #{listing.rooms && if_not_zero(listing.rooms, "quarto", "quartos")}
        #{listing.bathrooms && if_not_zero(listing.restrooms, "lavabo", "lavabos")}
        #{listing.restrooms && if_not_zero(listing.restrooms, "lavabo", "lavabos")}
        #{listing.garage_spots && if_not_zero(listing.garage_spots, "gargem", "garagens")}
        #{listing.matterport_code}
        #{listing.suites && if_not_zero(listing.suites, "suíte", "suítes")}
        #{
        listing.dependencies && if_not_zero(listing.dependencies, "dependência", "dependências")
      }
        #{listing.balconies && if_not_zero(listing.balconies, "varanda", "varandas")}
        #{listing.has_elevator && "elevador"}
        #{listing.is_exclusive && "exclusivo"}
        #{listing.is_release && "lançamento"}
        #{listing.address.street}
        #{listing.address.street_number}
        #{listing.complement}
        #{listing.address.neighborhood}
        #{listing.address.city}
        #{listing.address.state}
        #{listing.address.postal_code}
      """,
      inserted_at: listing.inserted_at,
      location: %{
        lat: listing.address.lat,
        lon: listing.address.lng
      }
    }
  end

  defp if_not_zero(0, _), do: ""
  defp if_not_zero(1, singular, _plural), do: "1 #{singular}"
  defp if_not_zero(num, _singular, plural), do: "#{num} #{plural}"
end
