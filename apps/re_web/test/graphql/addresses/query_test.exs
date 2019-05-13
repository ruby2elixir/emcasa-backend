defmodule ReWeb.GraphQL.Addresses.QueryTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok,
     unauthenticated_conn: conn,
     admin_user: admin_user,
     user_user: user_user,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user)}
  end

  describe "districts" do
    @districts_query """
      query Districts {
        districts {
          state
          city
          name
          stateSlug
          citySlug
          nameSlug
          description
        }
      }
    """

    test "admin should get districts", %{admin_conn: conn} do
      insert(:district, status: "inactive")
      insert_list(5, :district)
      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@districts_query))

      assert 5 == Enum.count(json_response(conn, 200)["data"]["districts"])
    end

    test "user should get districts", %{user_conn: conn} do
      insert(:district, status: "inactive")
      insert_list(5, :district)
      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@districts_query))

      assert 5 == Enum.count(json_response(conn, 200)["data"]["districts"])
    end

    test "anonymous should get districts", %{unauthenticated_conn: conn} do
      insert(:district, status: "inactive")
      insert_list(5, :district)
      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@districts_query))

      assert 5 == Enum.count(json_response(conn, 200)["data"]["districts"])
    end
  end

  describe "district" do
    @district_query """
      query District($stateSlug: String!, $citySlug: String!, $nameSlug: String!) {
        district(stateSlug: $stateSlug, citySlug: $citySlug, nameSlug: $nameSlug) {
          state
          city
          name
          stateSlug
          citySlug
          nameSlug
          description
        }
      }
    """

    test "admin should show district", %{admin_conn: conn} do
      insert(:district,
        name: "District Name",
        state: "RJ",
        city: "Rio de Janeiro",
        name_slug: "district-name",
        state_slug: "rj",
        city_slug: "rio-de-janeiro",
        description: "descr"
      )

      variables = %{
        "stateSlug" => "rj",
        "citySlug" => "rio-de-janeiro",
        "nameSlug" => "district-name"
      }

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@district_query, variables))

      assert %{
               "state" => "RJ",
               "city" => "Rio de Janeiro",
               "name" => "District Name",
               "stateSlug" => "rj",
               "citySlug" => "rio-de-janeiro",
               "nameSlug" => "district-name",
               "description" => "descr"
             } == json_response(conn, 200)["data"]["district"]
    end

    test "user should show district", %{user_conn: conn} do
      insert(:district,
        name: "District Name",
        state: "RJ",
        city: "Rio de Janeiro",
        name_slug: "district-name",
        state_slug: "rj",
        city_slug: "rio-de-janeiro",
        description: "descr"
      )

      variables = %{
        "stateSlug" => "rj",
        "citySlug" => "rio-de-janeiro",
        "nameSlug" => "district-name"
      }

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@district_query, variables))

      assert %{
               "state" => "RJ",
               "city" => "Rio de Janeiro",
               "name" => "District Name",
               "stateSlug" => "rj",
               "citySlug" => "rio-de-janeiro",
               "nameSlug" => "district-name",
               "description" => "descr"
             } == json_response(conn, 200)["data"]["district"]
    end

    test "anonymous should show district", %{unauthenticated_conn: conn} do
      insert(:district,
        name: "District Name",
        state: "RJ",
        city: "Rio de Janeiro",
        name_slug: "district-name",
        state_slug: "rj",
        city_slug: "rio-de-janeiro",
        description: "descr"
      )

      variables = %{
        "stateSlug" => "rj",
        "citySlug" => "rio-de-janeiro",
        "nameSlug" => "district-name"
      }

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@district_query, variables))

      assert %{
               "state" => "RJ",
               "city" => "Rio de Janeiro",
               "name" => "District Name",
               "stateSlug" => "rj",
               "citySlug" => "rio-de-janeiro",
               "nameSlug" => "district-name",
               "description" => "descr"
             } == json_response(conn, 200)["data"]["district"]
    end
  end

  describe "isCovered" do
    @is_covered_query """
      query AddressIsCovered (
        $state: String!,
        $city: String!,
        $neighborhood: String!
      ){
        addressIsCovered (
          state: $state,
          city: $city,
          neighborhood: $neighborhood
        )
      }
    """

    test "should confirm that address is is covered", %{unauthenticated_conn: conn} do
      district = insert(:district)

      variables = %{
        "state" => district.state,
        "city" => district.city,
        "neighborhood" => district.name
      }

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@is_covered_query, variables))

      assert json_response(conn, 200)["data"]["addressIsCovered"]
    end

    test "should deny that address is is covered", %{unauthenticated_conn: conn} do
      variables = %{
        "state" => "SP",
        "city" => "São Paulo",
        "neighborhood" => "Morumbi"
      }

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@is_covered_query, variables))

      refute json_response(conn, 200)["data"]["addressIsCovered"]
    end
  end
end
