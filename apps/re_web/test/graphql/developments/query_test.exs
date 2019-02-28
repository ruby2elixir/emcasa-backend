defmodule ReWeb.GraphQL.Developments.QueryTest do
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

  describe "developments" do
    @developments_query """
    query Developments {
      developments {
        name
        title
        phase
        builder
        description
      }
    }
    """

    test "admin should query developments", %{admin_conn: conn} do
      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@developments_query))

      assert json_response(conn, 200)["data"] == %{"developments" => []}
    end

    test "user should query developments", %{user_conn: conn} do
      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@developments_query))

      assert json_response(conn, 200)["data"] == %{"developments" => []}
    end

    test "anonymous should query developments", %{unauthenticated_conn: conn} do
      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@developments_query))

      assert json_response(conn, 200)["data"] == %{"developments" => []}
    end
  end
end
