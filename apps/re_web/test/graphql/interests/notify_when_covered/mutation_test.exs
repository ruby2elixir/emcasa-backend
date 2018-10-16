defmodule ReWeb.GraphQL.Interests.NotifyWhenCovered.MutationTest do
  use ReWeb.ConnCase

  alias ReWeb.AbsintheHelpers

  import Re.Factory

  alias Re.{
    Interests.NotifyWhenCovered,
    Repo
  }

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok, unauthenticated_conn: conn, user_user: user_user, user_conn: login_as(conn, user_user)}
  end

  test "anonymous should request notification when covered", %{unauthenticated_conn: conn} do
    %{id: address_id} = insert(:address)

    args = %{
      "name" => "Mah Name",
      "email" => "testemail@emcasa.com",
      "phone" => "123321123",
      "message" => "this website is cool",
      "addressId" => address_id
    }

    mutation = """
      mutation NotifyWhenCovered($name: String, $email: String, $phone: String, $message: String, $addressId: ID!) {
        notifyWhenCovered(name: $name, email: $email, phone: $phone, message: $message, addressId: $addressId) {
          name
          email
          phone
          message
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, args))

    assert %{
             "name" => "Mah Name",
             "email" => "testemail@emcasa.com",
             "phone" => "123321123",
             "message" => "this website is cool"
           } == json_response(conn, 200)["data"]["notifyWhenCovered"]

    assert notify_when_covered = Repo.get_by(NotifyWhenCovered, name: "Mah Name")
    assert address_id == notify_when_covered.address_id
  end

  test "user should request notification when covered", %{user_conn: conn, user_user: user} do
    %{id: address_id} = insert(:address)

    args = %{
      "name" => "Mah Name",
      "email" => "testemail@emcasa.com",
      "phone" => "123321123",
      "message" => "this website is cool",
      "addressId" => address_id
    }

    mutation = """
      mutation NotifyWhenCovered($name: String, $email: String, $phone: String, $message: String, $addressId: ID!) {
        notifyWhenCovered(name: $name, email: $email, phone: $phone, message: $message, addressId: $addressId) {
          name
          email
          phone
          message
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, args))

    assert %{
             "name" => "Mah Name",
             "email" => "testemail@emcasa.com",
             "phone" => "123321123",
             "message" => "this website is cool"
           } == json_response(conn, 200)["data"]["notifyWhenCovered"]

    assert notify_when_covered = Repo.get_by(NotifyWhenCovered, name: "Mah Name")
    assert user.id == notify_when_covered.user_id
    assert address_id == notify_when_covered.address_id
  end
end
