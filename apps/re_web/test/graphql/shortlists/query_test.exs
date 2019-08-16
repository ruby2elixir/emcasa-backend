defmodule ReWeb.GraphQL.Shortlists.QueryTest do
  use ReWeb.{
    AbsintheAssertions,
    ConnCase
  }

  import Mockery
  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, role: "admin")
    user_user = insert(:user, role: "user")

    {:ok,
     unauthenticated_conn: conn,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user)}
  end

  @http_client Application.get_env(:re, :http)

  test "should return listings from shortlist for admin", %{admin_conn: conn} do
    mock(
      @http_client,
      :get,
      {:ok,
       %{
         status_code: 200,
         body: "{}"
       }}
    )

    %{id: listing_id, uuid: listing_uuid} = insert(:listing)

    mock(
      HTTPoison,
      :get,
      {:ok,
       %{
         status_code: 200,
         body: "[\"#{listing_uuid}\"]"
       }}
    )

    variables = %{
      "opportunityId" => "0x01"
    }

    query = """
      query ShortlistListings ($opportunityId: String) {
        shortlistListings (opportunityId: $opportunityId) {
          id
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

    assert [%{"id" => to_string(listing_id)}] ==
             json_response(conn, 200)["data"]["shortlistListings"]
  end

  test "should return a forbidden for commom user", %{user_conn: conn} do
    variables = %{
      "opportunityId" => "0x01"
    }

    query = """
      query ShortlistListings ($opportunityId: String) {
        shortlistListings (opportunityId: $opportunityId) {
          id
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

    assert_forbidden_response(json_response(conn, 200))

    assert nil ==
             json_response(conn, 200)["data"]["shortlistListings"]
  end

  test "should return a unauthorize for unauthenticated user", %{conn: conn} do
    variables = %{
      "opportunityId" => "0x01"
    }

    query = """
      query ShortlistListings ($opportunityId: String) {
        shortlistListings (opportunityId: $opportunityId) {
          id
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

    assert_unauthorized_response(json_response(conn, 200))

    assert nil ==
             json_response(conn, 200)["data"]["shortlistListings"]
  end
end
