defmodule ReWeb.GraphQL.Listings.MutationTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.{
    AbsintheHelpers,
    Listing.MutationHelpers
  }

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    listing = build(:listing)
    address = build(:address)

    {:ok,
     unauthenticated_conn: conn,
     admin_user: admin_user,
     user_user: user_user,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user),
     old_listing: insert(:listing, user: user_user),
     old_address: insert(:address),
     listing: listing,
     address: address}
  end

  describe "insertListing" do
    test "admin should insert listing", %{
      admin_conn: conn,
      admin_user: user,
      listing: listing,
      address: address
    } do
      variables = MutationHelpers.insert_listing_variables(listing, address)

      mutation = MutationHelpers.insert_listing_mutation()

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

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
      assert inserted_listing["garageType"] == listing.garage_type |> String.upcase()
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
      listing: listing,
      address: address
    } do
      variables = MutationHelpers.insert_listing_variables(listing, address)

      mutation = MutationHelpers.insert_listing_mutation()

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

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
      assert inserted_listing["garageType"] == listing.garage_type |> String.upcase()
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

    test "admin should insert listing with address id", %{admin_conn: conn, old_address: address} do
      variables = %{
        "input" => %{
          "type" => "Apartamento",
          "addressId" => address.id
        }
      }

      mutation = """
        mutation InsertListing ($input: ListingInput!) {
          insertListing(input: $input) {
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

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "insertListing" => %{
                 "type" => "Apartamento",
                 "address" => %{
                   "id" => to_string(address.id),
                   "street" => address.street,
                   "postalCode" => address.postal_code,
                   "streetNumber" => address.street_number
                 }
               }
             } == json_response(conn, 200)["data"]
    end

    test "user should insert listing with address id", %{user_conn: conn, old_address: address} do
      variables = %{
        "input" => %{
          "type" => "Apartamento",
          "addressId" => address.id
        }
      }

      mutation = """
        mutation InsertListing ($input: ListingInput!) {
          insertListing(input: $input) {
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

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "insertListing" => %{
                 "type" => "Apartamento",
                 "address" => %{
                   "id" => to_string(address.id),
                   "street" => address.street,
                   "postalCode" => address.postal_code,
                   "streetNumber" => address.street_number
                 }
               }
             } == json_response(conn, 200)["data"]
    end

    test "admin should not insert listing without address", %{admin_conn: conn} do
      variables = %{"input" => %{"type" => "Apartamento"}}

      mutation = """
        mutation InsertListing($input: ListingInput!) {
          insertListing(input: $input) {
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

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Bad request", "code" => 400}] = json_response(conn, 200)["errors"]
    end

    test "user should not insert listing without address", %{user_conn: conn} do
      variables = %{"input" => %{"type" => "Apartamento"}}

      mutation = """
        mutation InsertListing ($input: ListingInput!) {
          insertListing(input: $input) {
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

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Bad request", "code" => 400}] = json_response(conn, 200)["errors"]
    end

    test "anonymous should not insert listing", %{
      unauthenticated_conn: conn,
      listing: listing,
      address: address
    } do
      variables = MutationHelpers.insert_listing_variables(listing, address)

      mutation = """
        mutation InsertListing($input: ListingInput!) {
          insertListing(input: $input) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end

    test "invalid listing", %{admin_conn: conn} do
      variables = %{
        "input" => %{
          "price" => 1,
          "type" => "Casa",
          "address" => %{
            "street" => "st",
            "streetNumber" => "1",
            "postalCode" => "123321123",
            "state" => "RJ",
            "city" => "Rio de J",
            "neighborhood" => "copa",
            "lat" => 10,
            "lng" => 10
          }
        }
      }

      mutation = """
        mutation InsertListing ($input: ListingInput!) {
          insertListing(input: $input)
          {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "price: must be greater than or equal to 250000", "code" => 422}] =
               json_response(conn, 200)["errors"]
    end
  end

  describe "updateListing" do
    test "admin should update listing", %{
      admin_conn: conn,
      old_listing: old_listing,
      listing: new_listing,
      address: new_address
    } do
      variables =
        MutationHelpers.update_listing_variables(old_listing.id, new_listing, new_address)

      mutation = MutationHelpers.update_listing_mutation()

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{"updateListing" => %{"address" => inserted_address} = updated_listing} =
               json_response(conn, 200)["data"]

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
      assert updated_listing["garageType"] == new_listing.garage_type |> String.upcase()
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
      old_listing: old_listing,
      listing: new_listing,
      address: new_address
    } do
      variables =
        MutationHelpers.update_listing_variables(old_listing.id, new_listing, new_address)

      mutation = MutationHelpers.update_listing_mutation()

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{"updateListing" => %{"address" => inserted_address} = updated_listing} =
               json_response(conn, 200)["data"]

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
      assert updated_listing["garageType"] == new_listing.garage_type |> String.upcase()
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

    test "user should not update listing", %{user_conn: conn, address: address, listing: listing} do
      not_current_user = insert(:user)
      old_listing = insert(:listing, user: not_current_user)

      variables = MutationHelpers.update_listing_variables(old_listing.id, listing, address)

      mutation = MutationHelpers.update_listing_mutation()

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Forbidden", "code" => 403}] = json_response(conn, 200)["errors"]
    end

    test "anonymous should not update listing", %{
      unauthenticated_conn: conn,
      old_listing: old_listing,
      listing: new_listing,
      address: new_address
    } do
      variables =
        MutationHelpers.update_listing_variables(old_listing.id, new_listing, new_address)

      mutation = MutationHelpers.update_listing_mutation()

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end
  end
end
