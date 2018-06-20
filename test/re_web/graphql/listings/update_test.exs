defmodule ReWeb.GraphQL.Listings.UpdateTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    listing = build(:listing)
    address = build(:address)

    update_input = """
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

    {:ok,
     unauthenticated_conn: conn,
     admin_user: admin_user,
     user_user: user_user,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user),
     update_input: update_input,
     old_listing: insert(:listing, user: user_user),
     old_address: insert(:address),
     new_listing: listing,
     new_address: address,
   }
  end

  test "admin should update listing", %{
    admin_conn: conn,
    update_input: update_input,
    old_listing: old_listing,
    new_listing: new_listing,
    new_address: new_address
  } do
    mutation = """
      mutation {
        updateListing(id: #{old_listing.id}, input: #{update_input}) {
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

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert %{"updateListing" => %{"address" => inserted_address} = updated_listing}
         = json_response(conn, 200)["data"]

    assert updated_listing["type"] == new_listing.type
    assert updated_listing["price"] == new_listing.price
    assert updated_listing["complement"] == new_listing.complement
    assert updated_listing["description"] == new_listing.description
    assert updated_listing["propertyTax"] == new_listing.property_tax
    assert updated_listing["maintenanceFee"] == new_listing.maintenance_fee
    assert updated_listing["floor"] == new_listing.floor
    assert updated_listing["rooms"] == new_listing.rooms
    assert updated_listing["bathrooms"] == new_listing.bathrooms
    assert updated_listing["restrooms"] == new_listing.restrooms
    assert updated_listing["area"] == new_listing.area
    assert updated_listing["garageSpots"] == new_listing.garage_spots
    assert updated_listing["suites"] == new_listing.suites
    assert updated_listing["dependencies"] == new_listing.dependencies
    assert updated_listing["balconies"] == new_listing.balconies
    assert updated_listing["hasElevator"] == new_listing.has_elevator
    assert updated_listing["matterportCode"] == new_listing.matterport_code
    assert updated_listing["isExclusive"] == new_listing.is_exclusive
    assert updated_listing["isRelease"] == new_listing.is_release

    assert inserted_address["city"] == new_address.city
    assert inserted_address["state"] == new_address.state
    assert inserted_address["lat"] == new_address.lat
    assert inserted_address["lng"] == new_address.lng
    assert inserted_address["neighborhood"] == new_address.neighborhood
    assert inserted_address["street"] == new_address.street
    assert inserted_address["streetNumber"] == new_address.street_number
    assert inserted_address["postalCode"] == new_address.postal_code
  end

  test "owner should update listing", %{
    user_conn: conn,
    update_input: update_input,
    old_listing: old_listing,
    new_listing: new_listing,
    new_address: new_address
  } do
    mutation = """
      mutation {
        updateListing(id: #{old_listing.id}, input: #{update_input}) {
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

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert %{"updateListing" => %{"address" => inserted_address} = updated_listing}
         = json_response(conn, 200)["data"]

    assert updated_listing["type"] == new_listing.type
    assert updated_listing["price"] == new_listing.price
    assert updated_listing["complement"] == new_listing.complement
    assert updated_listing["description"] == new_listing.description
    assert updated_listing["propertyTax"] == new_listing.property_tax
    assert updated_listing["maintenanceFee"] == new_listing.maintenance_fee
    assert updated_listing["floor"] == new_listing.floor
    assert updated_listing["rooms"] == new_listing.rooms
    assert updated_listing["bathrooms"] == new_listing.bathrooms
    assert updated_listing["restrooms"] == new_listing.restrooms
    assert updated_listing["area"] == new_listing.area
    assert updated_listing["garageSpots"] == new_listing.garage_spots
    assert updated_listing["suites"] == new_listing.suites
    assert updated_listing["dependencies"] == new_listing.dependencies
    assert updated_listing["balconies"] == new_listing.balconies
    assert updated_listing["hasElevator"] == new_listing.has_elevator
    assert updated_listing["matterportCode"] == old_listing.matterport_code
    assert updated_listing["isExclusive"] == new_listing.is_exclusive
    assert updated_listing["isRelease"] == new_listing.is_release

    refute updated_listing["isActive"]

    assert inserted_address["city"] == new_address.city
    assert inserted_address["state"] == new_address.state
    assert inserted_address["lat"] == new_address.lat
    assert inserted_address["lng"] == new_address.lng
    assert inserted_address["neighborhood"] == new_address.neighborhood
    assert inserted_address["street"] == new_address.street
    assert inserted_address["streetNumber"] == new_address.street_number
    assert inserted_address["postalCode"] == new_address.postal_code
  end

  test "user should not update listing", %{
    user_conn: conn,
    update_input: update_input
  } do
    not_current_user = insert(:user)
    old_listing = insert(:listing, user: not_current_user)

    mutation = """
      mutation {
        updateListing(id: #{old_listing.id}, input: #{update_input}) {
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

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert [%{"message" => "forbidden"}] = json_response(conn, 200)["errors"]
  end

  test "anonymous should not update listing", %{
    unauthenticated_conn: conn,
    update_input: update_input
  } do
    mutation = """
      mutation {
        insertListing(input: #{update_input}) {
          id
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert [%{"message" => "unauthorized"}] = json_response(conn, 200)["errors"]
  end
end
