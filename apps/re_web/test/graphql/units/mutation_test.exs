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

    # todo remove setup in favor of: https://github.com/rstacruz/cheatsheets/blob/master/exunit.md#setup-1
    unit_params =
      string_params_for(:unit, %{
        development_uuid: development.uuid,
        listing_id: listing.id,
        garage_type: "CONDOMINIUM"
      })
      |> Map.delete("uuid")

    old_unit =
      insert(:unit, %{
        development_uuid: development.uuid,
        listing_id: listing.id,
        garage_type: "CONDOMINIUM"
      })

    {
      :ok,
      unauthenticated_conn: conn,
      admin_conn: login_as(conn, admin_user),
      user_conn: login_as(conn, user_user),
      old_unit: old_unit,
      unit_params: unit_params
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
      unit_params: unit_params
    } do
      variables = %{"input" => unit_params}

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@insert_mutation, variables))

      assert %{
               "addUnit" => insert_unit
             } = json_response(conn, 200)["data"]

      assert insert_unit["uuid"]
      assert insert_unit["complement"] == unit_params["complement"]
      assert insert_unit["price"] == unit_params["price"]
      assert insert_unit["property_tax"] == unit_params["property_tax"]
      assert insert_unit["maintenance_fee"] == unit_params["maintenance_fee"]
      assert insert_unit["floor"] == unit_params["floor"]
      assert insert_unit["rooms"] == unit_params["rooms"]
      assert insert_unit["bathrooms"] == unit_params["bathrooms"]
      assert insert_unit["restrooms"] == unit_params["restrooms"]
      assert insert_unit["area"] == unit_params["area"]
      assert insert_unit["garage_spots"] == unit_params["garage_spots"]
      assert insert_unit["garage_type"] == String.downcase(unit_params["garage_type"])
      assert insert_unit["suites"] == unit_params["suites"]
      assert insert_unit["dependencies"] == unit_params["dependencies"]
      assert insert_unit["balconies"] == unit_params["balconies"]
      assert insert_unit["status"] == unit_params["status"]
    end

    test "regular user should not add unit", %{
      user_conn: conn,
      unit_params: unit_params
    } do
      variables = %{"input" => unit_params}

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@insert_mutation, variables))

      assert %{"addUnit" => nil} == json_response(conn, 200)["data"]

      assert_forbidden_response(json_response(conn, 200))
    end

    test "unauthenticated user should not add unit", %{
      unauthenticated_conn: conn,
      unit_params: unit_params
    } do
      variables = %{"input" => unit_params}

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
      unit_params: unit_params
    } do
      variables = update_unit_variables(old_unit.uuid, unit_params)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@update_mutation, variables))

      assert %{
               "updateUnit" => updated_unit
             } = json_response(conn, 200)["data"]

      assert updated_unit["uuid"]
      assert updated_unit["complement"] == unit_params["complement"]
      assert updated_unit["price"] == unit_params["price"]
      assert updated_unit["property_tax"] == unit_params["property_tax"]
      assert updated_unit["maintenance_fee"] == unit_params["maintenance_fee"]
      assert updated_unit["floor"] == unit_params["floor"]
      assert updated_unit["rooms"] == unit_params["rooms"]
      assert updated_unit["bathrooms"] == unit_params["bathrooms"]
      assert updated_unit["restrooms"] == unit_params["restrooms"]
      assert updated_unit["area"] == unit_params["area"]
      assert updated_unit["garage_spots"] == unit_params["garage_spots"]
      assert updated_unit["garage_type"] == String.downcase(unit_params["garage_type"])
      assert updated_unit["suites"] == unit_params["suites"]
      assert updated_unit["dependencies"] == unit_params["dependencies"]
      assert updated_unit["balconies"] == unit_params["balconies"]
      assert updated_unit["status"] == unit_params["status"]
    end

    test "commom user should not update a unit", %{
      user_conn: conn,
      old_unit: old_unit,
      unit_params: unit_params
    } do
      variables = update_unit_variables(old_unit.uuid, unit_params)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@update_mutation, variables))

      assert %{"updateUnit" => nil} == json_response(conn, 200)["data"]

      assert_forbidden_response(json_response(conn, 200))
    end

    test "unauthenticated user should not update a unit", %{
      unauthenticated_conn: conn,
      old_unit: old_unit,
      unit_params: unit_params
    } do
      variables = update_unit_variables(old_unit.uuid, unit_params)

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@update_mutation, variables))

      assert %{"updateUnit" => nil} == json_response(conn, 200)["data"]

      assert_unauthorized_response(json_response(conn, 200))
    end
  end

  def update_unit_variables(uuid, unit) do
    %{
      "uuid" => uuid,
      "input" => unit
    }
  end
end
