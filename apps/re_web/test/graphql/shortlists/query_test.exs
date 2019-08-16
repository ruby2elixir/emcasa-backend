defmodule ReWeb.GraphQL.Shortlists.QueryTest do
  use ReWeb.ConnCase

  import Mockery
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

  @http_client Application.get_env(:re, :http)

  @tag dev: true
  test "should return listings with relaxed filters for admin", %{admin_conn: conn} do
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
end
