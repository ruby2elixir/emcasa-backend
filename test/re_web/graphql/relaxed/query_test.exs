defmodule ReWeb.GraphQL.Relaxed.QueryTest do
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

  test "should return listings with relaxed filters for admin", %{admin_conn: conn} do
    %{id: listing_id} = insert(:listing, rooms: 3)

    variables = %{
      "filters" => %{
        "maxRooms" => 2
      }
    }

    query = """
      query RelaxedListings ($filters: ListingFilterInput) {
        relaxedListings (filters: $filters) {
          remainingCount
          listings {
            id
          }
          filters {
            maxRooms
          }
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

    assert %{
             "listings" => [%{"id" => to_string(listing_id)}],
             "remainingCount" => 0,
             "filters" => %{
               "maxRooms" => 3
             }
           } == json_response(conn, 200)["data"]["relaxedListings"]
  end

  test "should return listings with relaxed filters for user", %{user_conn: conn} do
    %{id: listing_id} = insert(:listing, rooms: 3)

    variables = %{
      "filters" => %{
        "maxRooms" => 2
      }
    }

    query = """
      query RelaxedListings ($filters: ListingFilterInput) {
        relaxedListings (filters: $filters) {
          remainingCount
          listings {
            id
          }
          filters {
            maxRooms
          }
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

    assert %{
             "listings" => [%{"id" => to_string(listing_id)}],
             "remainingCount" => 0,
             "filters" => %{
               "maxRooms" => 3
             }
           } == json_response(conn, 200)["data"]["relaxedListings"]
  end

  test "should return listings with relaxed filters for anonymous", %{unauthenticated_conn: conn} do
    %{id: listing_id} = insert(:listing, rooms: 3)

    variables = %{
      "filters" => %{
        "maxRooms" => 2
      }
    }

    query = """
      query RelaxedListings ($filters: ListingFilterInput) {
        relaxedListings (filters: $filters) {
          remainingCount
          listings {
            id
          }
          filters {
            maxRooms
          }
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

    assert %{
             "listings" => [%{"id" => to_string(listing_id)}],
             "remainingCount" => 0,
             "filters" => %{
               "maxRooms" => 3
             }
           } == json_response(conn, 200)["data"]["relaxedListings"]
  end
end
