defmodule ReWeb.AbsintheHelpers do
  @moduledoc """
  Helpers for absinthe endpoint testing
  """
  def query_skeleton(query, query_name) do
    %{
      "operationName" => "#{query_name}",
      "query" => "query #{query_name} #{query}",
      "variables" => "{}"
    }
  end

  def mutation_skeleton(query) do
    %{
      "operationName" => "",
      "query" => "#{query}",
      "variables" => ""
    }
  end

  def listing_input(listing, address) do
    """
      {
        type: "#{listing.type}",
        address: {
          city: "#{address.city}",
          state: "#{address.state}",
          lat: #{address.lat},
          lng: #{address.lng},
          neighborhood: "#{address.neighborhood}",
          street: "#{address.street}",
          streetNumber: "#{address.street_number}",
          postalCode: "#{address.postal_code}"
        }
        price: #{listing.price},
        complement: "#{listing.complement}",
        description: "#{listing.description}",
        propertyTax: #{listing.property_tax},
        maintenanceFee: #{listing.maintenance_fee},
        floor: "#{listing.floor}",
        rooms: #{listing.rooms},
        bathrooms: #{listing.bathrooms},
        restrooms: #{listing.restrooms},
        area: #{listing.area},
        garageSpots: #{listing.garage_spots},
        suites: #{listing.suites},
        dependencies: #{listing.dependencies},
        balconies: #{listing.balconies},
        hasElevator: #{listing.has_elevator},
        matterportCode: "#{listing.matterport_code}",
        isExclusive: #{listing.is_exclusive},
        isRelease: #{listing.is_release}
      }
    """
  end

  def listing_mutation(input, type, listing_id \\ nil) do
    id = id_if_has(listing_id)

    """
      mutation {
        #{type}(#{id}input: #{input}) {
          id
          type
          address {
            city
            state
            lat
            lng
            neighborhood
            street
            streetNumber
            postalCode
          }
          owner {
            id
          }
          price
          complement
          description
          propertyTax
          maintenanceFee
          floor
          rooms
          bathrooms
          restrooms
          area
          garageSpots
          suites
          dependencies
          balconies
          hasElevator
          matterportCode
          isActive
          isExclusive
          isRelease
        }
      }
    """
  end

  defp id_if_has(nil), do: ""
  defp id_if_has(listing_id), do: "id: #{listing_id}, "
end
