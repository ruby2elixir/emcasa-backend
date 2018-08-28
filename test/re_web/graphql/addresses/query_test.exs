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
    test "admin should get districts", %{admin_conn: conn} do
      insert(:district, state: "RJ", city: "Rio de Janeiro", name: "Botafogo", description: "descr")

      query = """
        query Districts {
          districts {
            state
            city
            name
            description
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert [
              %{
               "state" => "RJ",
               "city" => "Rio de Janeiro",
               "name" => "Botafogo",
               "description" => "descr"
               }
             ] == json_response(conn, 200)["data"]["districts"]
    end

    test "user should get districts", %{user_conn: conn} do
      insert(:district, state: "RJ", city: "Rio de Janeiro", name: "Botafogo", description: "descr")

      query = """
        query Districts {
          districts {
            state
            city
            name
            description
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert [
              %{
               "state" => "RJ",
               "city" => "Rio de Janeiro",
               "name" => "Botafogo",
               "description" => "descr"
               }
             ] == json_response(conn, 200)["data"]["districts"]
    end

    test "anonymous should get districts", %{unauthenticated_conn: conn} do
      insert(:district, state: "RJ", city: "Rio de Janeiro", name: "Botafogo", description: "descr")

      query = """
        query Districts {
          districts {
            state
            city
            name
            description
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert [
              %{
               "state" => "RJ",
               "city" => "Rio de Janeiro",
               "name" => "Botafogo",
               "description" => "descr"
               }
             ] == json_response(conn, 200)["data"]["districts"]
    end
  end
end
