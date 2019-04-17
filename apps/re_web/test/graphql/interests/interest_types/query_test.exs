defmodule ReWeb.GraphQL.Interests.InterestType.QueryTest do
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

  test "should query interest types for admins", %{admin_conn: conn} do
    %{id: id1, name: name1} = insert(:interest_type, name: "type1", enabled: true)
    %{id: id2, name: name2} = insert(:interest_type, name: "type2", enabled: true)
    insert(:interest_type, name: "type3", enabled: false)

    query = """
      query InterestTypes {
        interestTypes {
          id
          name
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

    assert types = json_response(conn, 200)["data"]["interestTypes"]

    assert Enum.member?(types, %{"id" => to_string(id1), "name" => name1})
    assert Enum.member?(types, %{"id" => to_string(id2), "name" => name2})
  end

  test "should query interest types for user", %{user_conn: conn} do
    %{id: id1, name: name1} = insert(:interest_type, name: "type1", enabled: true)
    %{id: id2, name: name2} = insert(:interest_type, name: "type2", enabled: true)
    insert(:interest_type, name: "type3", enabled: false)

    query = """
      query InterestTypes {
        interestTypes {
          id
          name
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

    assert types = json_response(conn, 200)["data"]["interestTypes"]

    assert Enum.member?(types, %{"id" => to_string(id1), "name" => name1})
    assert Enum.member?(types, %{"id" => to_string(id2), "name" => name2})
  end

  test "should query interest types for anonymous", %{unauthenticated_conn: conn} do
    %{id: id1, name: name1} = insert(:interest_type, name: "type1", enabled: true)
    %{id: id2, name: name2} = insert(:interest_type, name: "type2", enabled: true)
    insert(:interest_type, name: "type3", enabled: false)

    query = """
      query InterestTypes {
        interestTypes {
          id
          name
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

    assert types = json_response(conn, 200)["data"]["interestTypes"]

    assert Enum.member?(types, %{"id" => to_string(id1), "name" => name1})
    assert Enum.member?(types, %{"id" => to_string(id2), "name" => name2})
  end
end
