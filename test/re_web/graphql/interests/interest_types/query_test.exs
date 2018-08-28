defmodule ReWeb.GraphQL.InterestType.QueryTest do
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
    insert(:interest_type, name: "type2", enabled: false)

    query = """
      query InterestTypes {
        interestTypes {
          id
          name
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

    assert [
             %{"id" => "1", "name" => "Me ligue dentro de 5 minutos"},
             %{"id" => "2", "name" => "Me ligue em um horário específico"},
             %{"id" => "3", "name" => "Agendamento por e-mail"},
             %{"id" => "4", "name" => "Agendamento por Whatsapp"}
           ] == json_response(conn, 200)["data"]["interestTypes"]
  end

  test "should query interest types for user", %{user_conn: conn} do
    insert(:interest_type, name: "type2", enabled: false)

    query = """
      query InterestTypes {
        interestTypes {
          id
          name
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

    assert [
             %{"id" => "1", "name" => "Me ligue dentro de 5 minutos"},
             %{"id" => "2", "name" => "Me ligue em um horário específico"},
             %{"id" => "3", "name" => "Agendamento por e-mail"},
             %{"id" => "4", "name" => "Agendamento por Whatsapp"}
           ] == json_response(conn, 200)["data"]["interestTypes"]
  end

  test "should query interest types for anonymous", %{unauthenticated_conn: conn} do
    insert(:interest_type, name: "type2", enabled: false)

    query = """
      query InterestTypes {
        interestTypes {
          id
          name
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

    assert [
             %{"id" => "1", "name" => "Me ligue dentro de 5 minutos"},
             %{"id" => "2", "name" => "Me ligue em um horário específico"},
             %{"id" => "3", "name" => "Agendamento por e-mail"},
             %{"id" => "4", "name" => "Agendamento por Whatsapp"}
           ] == json_response(conn, 200)["data"]["interestTypes"]
  end
end
