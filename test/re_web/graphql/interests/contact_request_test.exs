defmodule ReWeb.GraphQL.Interests.ContactRequestTest do
  use ReWeb.ConnCase

  alias ReWeb.AbsintheHelpers

  import Re.Factory

  alias Re.{
    Interests.ContactRequest,
    Repo
  }

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok,
     unauthenticated_conn: conn,
     user_user: user_user,
     user_conn: login_as(conn, user_user)
    }
  end

  @request_contact_input """
      name: "Mah Name",
      email: "testemail@emcasa.com",
      phone: "123321123",
      message: "this website is cool"
  """

  test "anonymous should request contact", %{unauthenticated_conn: conn} do
    mutation = """
      mutation {
        requestContact(#{@request_contact_input}) {
          name
          email
          phone
          message
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert %{"requestContact" =>
              %{"name" => "Mah Name",
                "email" => "testemail@emcasa.com",
                "phone" => "123321123",
                "message" => "this website is cool"
            }} = json_response(conn, 200)["data"]

    assert Repo.get_by(ContactRequest, name: "Mah Name")
  end

  test "user should request contact", %{user_conn: conn, user_user: user} do
    mutation = """
      mutation {
        requestContact(#{@request_contact_input}) {
          name
          email
          phone
          message
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert %{"requestContact" =>
              %{"name" => "Mah Name",
                "email" => "testemail@emcasa.com",
                "phone" => "123321123",
                "message" => "this website is cool"
            }} = json_response(conn, 200)["data"]
    assert contact_request = Repo.get_by(ContactRequest, name: "Mah Name")
    assert contact_request.user_id == user.id
  end
end
