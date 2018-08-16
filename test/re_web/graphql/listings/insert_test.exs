defmodule ReWeb.GraphQL.Listings.InsertTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    listing = build(:listing)
    address = build(:address)

    insert_input = AbsintheHelpers.listing_input(listing, address)

    {:ok,
     unauthenticated_conn: conn,
     admin_user: admin_user,
     user_user: user_user,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user),
     insert_input: insert_input,
     listing: listing,
     address: address}
  end

  test "admin should insert listing", %{
    admin_conn: conn,
    admin_user: user,
    insert_input: insert_input,
    listing: listing,
    address: address
  } do
    mutation = AbsintheHelpers.listing_mutation(insert_input, "insertListing")

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert %{
             "insertListing" =>
               %{"address" => inserted_address, "owner" => owner} = inserted_listing
           } = json_response(conn, 200)["data"]

    assert inserted_listing["id"]
    assert inserted_listing["type"] == listing.type
    assert inserted_listing["price"] == listing.price
    assert inserted_listing["complement"] == listing.complement
    assert inserted_listing["description"] == listing.description
    assert inserted_listing["propertyTax"] == listing.property_tax
    assert inserted_listing["maintenanceFee"] == listing.maintenance_fee
    assert inserted_listing["floor"] == listing.floor
    assert inserted_listing["rooms"] == listing.rooms
    assert inserted_listing["bathrooms"] == listing.bathrooms
    assert inserted_listing["restrooms"] == listing.restrooms
    assert inserted_listing["area"] == listing.area
    assert inserted_listing["garageSpots"] == listing.garage_spots
    assert inserted_listing["suites"] == listing.suites
    assert inserted_listing["dependencies"] == listing.dependencies
    assert inserted_listing["balconies"] == listing.balconies
    assert inserted_listing["hasElevator"] == listing.has_elevator
    assert inserted_listing["matterportCode"] == listing.matterport_code
    assert inserted_listing["isExclusive"] == listing.is_exclusive
    assert inserted_listing["isRelease"] == listing.is_release

    refute inserted_listing["isActive"]

    assert inserted_address["city"] == address.city
    assert inserted_address["state"] == address.state
    assert inserted_address["lat"] == address.lat
    assert inserted_address["lng"] == address.lng
    assert inserted_address["neighborhood"] == address.neighborhood
    assert inserted_address["street"] == address.street
    assert inserted_address["streetNumber"] == address.street_number
    assert inserted_address["postalCode"] == address.postal_code

    assert owner["id"] == to_string(user.id)
  end

  test "user should insert listing", %{
    user_conn: conn,
    user_user: user,
    insert_input: insert_input,
    listing: listing,
    address: address
  } do
    mutation = AbsintheHelpers.listing_mutation(insert_input, "insertListing")

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert %{
             "insertListing" =>
               %{"address" => inserted_address, "owner" => owner} = inserted_listing
           } = json_response(conn, 200)["data"]

    assert inserted_listing["id"]
    assert inserted_listing["type"] == listing.type
    assert inserted_listing["price"] == listing.price
    assert inserted_listing["complement"] == listing.complement
    assert inserted_listing["description"] == listing.description
    assert inserted_listing["propertyTax"] == listing.property_tax
    assert inserted_listing["maintenanceFee"] == listing.maintenance_fee
    assert inserted_listing["floor"] == listing.floor
    assert inserted_listing["rooms"] == listing.rooms
    assert inserted_listing["bathrooms"] == listing.bathrooms
    assert inserted_listing["restrooms"] == listing.restrooms
    assert inserted_listing["area"] == listing.area
    assert inserted_listing["garageSpots"] == listing.garage_spots
    assert inserted_listing["suites"] == listing.suites
    assert inserted_listing["dependencies"] == listing.dependencies
    assert inserted_listing["balconies"] == listing.balconies
    assert inserted_listing["hasElevator"] == listing.has_elevator
    assert inserted_listing["matterportCode"] == nil
    assert inserted_listing["isExclusive"] == listing.is_exclusive
    assert inserted_listing["isRelease"] == listing.is_release

    refute inserted_listing["isActive"]

    assert inserted_address["city"] == address.city
    assert inserted_address["state"] == address.state
    assert inserted_address["lat"] == address.lat
    assert inserted_address["lng"] == address.lng
    assert inserted_address["neighborhood"] == address.neighborhood
    assert inserted_address["street"] == address.street
    assert inserted_address["streetNumber"] == address.street_number
    assert inserted_address["postalCode"] == address.postal_code

    assert owner["id"] == to_string(user.id)
  end

  test "admin should insert listing with address id", %{
    admin_conn: conn
  } do
    address = insert(:address)

    mutation = """
      mutation {
        insertListing(input: {
          type: "Apartamento",
          addressId: #{address.id}
          }) {
            type
            address {
              id
              street
              postalCode
              streetNumber
            }
          }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert %{
             "insertListing" =>
               %{"type" => "Apartamento",
                 "address" => %{
                    "id" => to_string(address.id),
                    "street" => address.street,
                    "postalCode" => address.postal_code,
                    "streetNumber" => address.street_number
                  }}
           } == json_response(conn, 200)["data"]
  end

  test "user should insert listing with address id", %{
    user_conn: conn
  } do
    address = insert(:address)

    mutation = """
      mutation {
        insertListing(input: {
          type: "Apartamento",
          addressId: #{address.id}
          }) {
            type
            address {
              id
              street
              postalCode
              streetNumber
            }
          }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert %{
             "insertListing" =>
               %{"type" => "Apartamento",
                 "address" => %{
                    "id" => to_string(address.id),
                    "street" => address.street,
                    "postalCode" => address.postal_code,
                    "streetNumber" => address.street_number
                  }}
           } == json_response(conn, 200)["data"]
  end

  test "anonymous should not insert listing", %{
    unauthenticated_conn: conn,
    insert_input: insert_input
  } do
    mutation = """
      mutation {
        insertListing(input: #{insert_input}) {
          id
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
  end

  test "invalid listing", %{admin_conn: conn} do
    mutation = """
      mutation {
        insertListing(input:{
        price: 1
        type: "Casa",
        address: {
          street: "st",
          streetNumber: "1",
          postalCode: "123321123",
          state: "RJ",
          city: "Rio de J",
          neighborhood: "copa",
          lat: 10,
          lng: 10
        }})
        {
          id
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert [%{"message" => "price: must be greater than or equal to 550000", "code" => 422}] =
             json_response(conn, 200)["errors"]
  end
end
