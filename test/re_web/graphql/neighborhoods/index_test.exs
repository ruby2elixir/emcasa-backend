defmodule ReWeb.GraphQL.Neighborhoods.IndexTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok,
     unauthenticated_conn: conn,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user)}
  end

  test "admin should query neighborhoods", %{admin_conn: conn} do
    insert(:listing, address: build(:address, neighborhood: "Copacabana"), is_active: true)
    insert(:listing, address: build(:address, neighborhood: "Botafogo"), is_active: false)
    insert(:listing, address: build(:address, neighborhood: "Leblon"), is_active: true)

    query = "{ neighborhoods } "

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listings"))

    assert %{"neighborhoods" => ["Copacabana", "Leblon"]} = json_response(conn, 200)["data"]
  end

  test "user should query neighborhoods", %{admin_conn: conn} do
    insert(:listing, address: build(:address, neighborhood: "Copacabana"), is_active: true)
    insert(:listing, address: build(:address, neighborhood: "Botafogo"), is_active: false)
    insert(:listing, address: build(:address, neighborhood: "Leblon"), is_active: true)

    query = "{ neighborhoods } "

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listings"))

    assert %{"neighborhoods" => ["Copacabana", "Leblon"]} = json_response(conn, 200)["data"]
  end

  test "anonymous should query neighborhoods", %{admin_conn: conn} do
    insert(:listing, address: build(:address, neighborhood: "Copacabana"), is_active: true)
    insert(:listing, address: build(:address, neighborhood: "Botafogo"), is_active: false)
    insert(:listing, address: build(:address, neighborhood: "Leblon"), is_active: true)

    query = "{ neighborhoods } "

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listings"))

    assert %{"neighborhoods" => ["Copacabana", "Leblon"]} = json_response(conn, 200)["data"]
  end
end
