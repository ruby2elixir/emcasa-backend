defmodule ReWeb.GraphQL.Units.MutationTest do
  use ReWeb.{AbsintheAssertions, ConnCase}

  import Re.Factory

  alias ReWeb.{
    AbsintheHelpers
  }

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    development = insert(:development)
    listing = insert(:listing, development: development)

    unit =
      insert(:unit, %{
        development_uuid: development.uuid,
        listing_id: listing.id
      })

    {
      :ok,
      unauthenticated_conn: conn,
      admin_conn: login_as(conn, admin_user),
      user_conn: login_as(conn, user_user),
      development: development,
      listing: listing,
      new_unit: build(:unit),
      old_unit: unit
    }
  end

  describe "insert/2" do
    @insert_mutation """
      mutation AddUnit ($input: UnitInput!) {
        addUnit(input: $input) {
          uuid
          complement
          price
          property_tax
          maintenance_fee
          floor
          rooms
          bathrooms
          restrooms
          area
          garage_spots
          garage_type
          suites
          dependencies
          balconies
          status
          }
        }
    """

    test "admin should add unit", %{
      admin_conn: conn,
      new_unit: new_unit,
      development: development,
      listing: listing
    } do
      variables = insert_unit_variables(new_unit, development, listing)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@insert_mutation, variables))

      assert %{
               "addUnit" => insert_unit
             } = json_response(conn, 200)["data"]

      assert insert_unit["uuid"]
      assert insert_unit["complement"] == new_unit.complement
      assert insert_unit["price"] == new_unit.price
      assert insert_unit["property_tax"] == new_unit.property_tax
      assert insert_unit["maintenance_fee"] == new_unit.maintenance_fee
      assert insert_unit["floor"] == new_unit.floor
      assert insert_unit["rooms"] == new_unit.rooms
      assert insert_unit["bathrooms"] == new_unit.bathrooms
      assert insert_unit["restrooms"] == new_unit.restrooms
      assert insert_unit["area"] == new_unit.area
      assert insert_unit["garage_spots"] == new_unit.garage_spots
      assert insert_unit["garage_type"] == new_unit.garage_type
      assert insert_unit["suites"] == new_unit.suites
      assert insert_unit["dependencies"] == new_unit.dependencies
      assert insert_unit["balconies"] == new_unit.balconies
      assert insert_unit["status"] == new_unit.status
    end

    test "regular user should not add unit", %{
      user_conn: conn,
      new_unit: new_unit,
      development: development,
      listing: listing
    } do
      variables = insert_unit_variables(new_unit, development, listing)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@insert_mutation, variables))

      assert %{"addUnit" => nil} == json_response(conn, 200)["data"]

      assert_forbidden_response(json_response(conn, 200))
    end

    test "unauthenticated user should not add unit", %{
      unauthenticated_conn: conn,
      new_unit: new_unit,
      development: development,
      listing: listing
    } do
      variables = insert_unit_variables(new_unit, development, listing)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@insert_mutation, variables))

      assert %{"addUnit" => nil} == json_response(conn, 200)["data"]

      assert_unauthorized_response(json_response(conn, 200))
    end
  end

  describe "updateUnit" do
    @update_mutation """
      mutation UpdateUnit ($uuid: UUID!, $input: UnitInput!) {
        updateUnit(uuid: $uuid, input: $input) {
          uuid
          complement
          price
          property_tax
          maintenance_fee
          floor
          rooms
          bathrooms
          restrooms
          area
          garage_spots
          garage_type
          suites
          dependencies
          balconies
          status
          }
        }
    """

    test "admin should update a unit", %{
      admin_conn: conn,
      old_unit: old_unit,
      new_unit: new_unit,
      development: development,
      listing: listing
    } do
      variables = update_unit_variables(old_unit.uuid, new_unit, development, listing)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@update_mutation, variables))

      assert %{
               "updateUnit" => updated_unit
             } = json_response(conn, 200)["data"]

      assert updated_unit["uuid"]
      assert updated_unit["complement"] == new_unit.complement
      assert updated_unit["price"] == new_unit.price
      assert updated_unit["property_tax"] == new_unit.property_tax
      assert updated_unit["maintenance_fee"] == new_unit.maintenance_fee
      assert updated_unit["floor"] == new_unit.floor
      assert updated_unit["rooms"] == new_unit.rooms
      assert updated_unit["bathrooms"] == new_unit.bathrooms
      assert updated_unit["restrooms"] == new_unit.restrooms
      assert updated_unit["area"] == new_unit.area
      assert updated_unit["garage_spots"] == new_unit.garage_spots
      assert updated_unit["garage_type"] == new_unit.garage_type
      assert updated_unit["suites"] == new_unit.suites
      assert updated_unit["dependencies"] == new_unit.dependencies
      assert updated_unit["balconies"] == new_unit.balconies
      assert updated_unit["status"] == new_unit.status
    end

    test "commom user should not update a unit", %{
      user_conn: conn,
      old_unit: old_unit,
      new_unit: new_unit,
      development: development,
      listing: listing
    } do
      variables = update_unit_variables(old_unit.uuid, new_unit, development, listing)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@update_mutation, variables))

      assert %{"updateUnit" => nil} == json_response(conn, 200)["data"]

      assert_forbidden_response(json_response(conn, 200))
    end

    test "unauthenticated user should not update a unit", %{
      unauthenticated_conn: conn,
      old_unit: old_unit,
      new_unit: new_unit,
      development: development,
      listing: listing
    } do
      variables = update_unit_variables(old_unit.uuid, new_unit, development, listing)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@update_mutation, variables))

      assert %{"updateUnit" => nil} == json_response(conn, 200)["data"]

      assert_unauthorized_response(json_response(conn, 200))
    end
  end

  def insert_unit_variables(unit, development, listing) do
    %{
      "input" => unit_input(unit, development, listing)
    }
  end

  def update_unit_variables(uuid, unit, development, listing) do
    %{
      "uuid" => uuid,
      "input" => unit_input(unit, development, listing)
    }
  end

  defp unit_input(unit, development, listing) do
    %{
      "complement" => unit.complement,
      "price" => unit.price,
      "property_tax" => unit.property_tax,
      "maintenance_fee" => unit.maintenance_fee,
      "floor" => unit.floor,
      "rooms" => unit.rooms,
      "bathrooms" => unit.bathrooms,
      "restrooms" => unit.restrooms,
      "area" => unit.area,
      "garage_spots" => unit.garage_spots,
      "garage_type" => String.upcase(unit.garage_type),
      "suites" => unit.suites,
      "dependencies" => unit.dependencies,
      "balconies" => unit.balconies,
      "status" => unit.status,
      "listing_id" => listing.id,
      "development_uuid" => development.uuid
    }
  end
end
