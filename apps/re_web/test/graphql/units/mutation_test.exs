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

    unit = build(:unit)

    {
      :ok,
      unauthenticated_conn: conn,
      admin_conn: login_as(conn, admin_user),
      user_conn: login_as(conn, user_user),
      unit: unit,
      development: development,
      listing: listing
    }
  end

  describe "insert/2" do
    @insert_mutation """
      mutation InsertUnit ($input: UnitInput!) {
        insertUnit(input: $input) {
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

    test "admin should insert unit", %{
      admin_conn: conn,
      unit: unit,
      development: development,
      listing: listing
    } do
      variables = insert_unit_variables(unit, development, listing)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@insert_mutation, variables))

      assert %{
               "insertUnit" => insert_unit
             } = json_response(conn, 200)["data"]

      assert insert_unit["uuid"]
      assert insert_unit["complement"] == unit.complement
      assert insert_unit["price"] == unit.price
      assert insert_unit["property_tax"] == unit.property_tax
      assert insert_unit["maintenance_fee"] == unit.maintenance_fee
      assert insert_unit["floor"] == unit.floor
      assert insert_unit["rooms"] == unit.rooms
      assert insert_unit["bathrooms"] == unit.bathrooms
      assert insert_unit["restrooms"] == unit.restrooms
      assert insert_unit["area"] == unit.area
      assert insert_unit["garage_spots"] == unit.garage_spots
      assert insert_unit["garage_type"] == unit.garage_type
      assert insert_unit["suites"] == unit.suites
      assert insert_unit["dependencies"] == unit.dependencies
      assert insert_unit["balconies"] == unit.balconies
    end

    test "regular user should not insert unit", %{
      user_conn: conn,
      unit: unit,
      development: development,
      listing: listing
    } do
      variables = insert_unit_variables(unit, development, listing)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@insert_mutation, variables))

      assert %{"insertUnit" => nil} == json_response(conn, 200)["data"]

      assert_forbidden_response(json_response(conn, 200))
    end

    test "unauthenticated user should not insert unit", %{
      unauthenticated_conn: conn,
      unit: unit,
      development: development,
      listing: listing
    } do
      variables = insert_unit_variables(unit, development, listing)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@insert_mutation, variables))

      assert %{"insertUnit" => nil} == json_response(conn, 200)["data"]

      assert_unauthorized_response(json_response(conn, 200))
    end
  end

  def insert_unit_variables(unit, development, listing) do
    %{
      "input" => %{
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
        "garage_type" => unit.garage_type,
        "suites" => unit.suites,
        "dependencies" => unit.dependencies,
        "balconies" => unit.balconies,
        "status" => unit.status,
        "development_uuid" => development.uuid,
        "listing_id" => listing.id
      }
    }
  end
end
