defmodule ReWeb.GraphQL.Interests.MutationTest do
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

    {:ok, unauthenticated_conn: conn, user_user: user_user, user_conn: login_as(conn, user_user)}
  end

  @variables %{
    "name" => "Mah Name",
    "email" => "testemail@emcasa.com",
    "phone" => "123321123",
    "message" => "this website is cool"
  }

  test "anonymous should request contact", %{unauthenticated_conn: conn} do
    mutation = """
      mutation RequestContact($name: String, $email: String, $phone: String, $message: String) {
        requestContact(name: $name, email: $email, phone: $phone, message: $message) {
          name
          email
          phone
          message
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, @variables))

    assert %{
               "name" => "Mah Name",
               "email" => "testemail@emcasa.com",
               "phone" => "123321123",
               "message" => "this website is cool"
           } == json_response(conn, 200)["data"]["requestContact"]

    assert Repo.get_by(ContactRequest, name: "Mah Name")
  end

  test "user should request contact", %{user_conn: conn, user_user: user} do
    mutation = """
      mutation RequestContact($name: String, $email: String, $phone: String, $message: String) {
        requestContact(name: $name, email: $email, phone: $phone, message: $message) {
          name
          email
          phone
          message
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, @variables))

    assert %{
               "name" => "Mah Name",
               "email" => "testemail@emcasa.com",
               "phone" => "123321123",
               "message" => "this website is cool"
           } == json_response(conn, 200)["data"]["requestContact"]

    assert contact_request = Repo.get_by(ContactRequest, name: "Mah Name")
    assert contact_request.user_id == user.id
  end
end
