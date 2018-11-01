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
    args = %{
      "name" => "Mah Name",
      "email" => "testemail@emcasa.com",
      "phone" => "123321123",
      "message" => "this website is cool",
      "state" => "SP",
      "city" => "São Paulo",
      "neighborhood" => "Morumbi"
    }

    mutation = """
      mutation NotifyWhenCovered($name: String, $email: String, $phone: String, $message: String, $state: String!, $city: String!, $neighborhood: String!) {
        notifyWhenCovered(name: $name, email: $email, phone: $phone, message: $message, state: $state, city: $city, neighborhood: $neighborhood) {
          name
          email
          phone
          message
          state
          city
          neighborhood
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, args))

    assert %{
             "name" => "Mah Name",
             "email" => "testemail@emcasa.com",
             "phone" => "123321123",
             "message" => "this website is cool",
             "state" => "SP",
             "city" => "São Paulo",
             "neighborhood" => "Morumbi"
           } == json_response(conn, 200)["data"]["notifyWhenCovered"]

    assert notify_when_covered = Repo.get_by(NotifyWhenCovered, name: "Mah Name")
    assert "testemail@emcasa.com" == notify_when_covered.email
    assert "123321123" == notify_when_covered.phone
    assert "this website is cool" == notify_when_covered.message
    assert "SP" == notify_when_covered.state
    assert "São Paulo" == notify_when_covered.city
    assert "Morumbi" == notify_when_covered.neighborhood
  end

  test "user should request notification when covered", %{user_conn: conn} do
    args = %{
      "name" => "Mah Name",
      "email" => "testemail@emcasa.com",
      "phone" => "123321123",
      "message" => "this website is cool",
      "state" => "SP",
      "city" => "São Paulo",
      "neighborhood" => "Morumbi"
    }

    mutation = """
      mutation NotifyWhenCovered($name: String, $email: String, $phone: String, $message: String, $state: String!, $city: String!, $neighborhood: String!) {
        notifyWhenCovered(name: $name, email: $email, phone: $phone, message: $message, state: $state, city: $city, neighborhood: $neighborhood) {
          name
          email
          phone
          message
          state
          city
          neighborhood
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, args))

    assert %{
             "name" => "Mah Name",
             "email" => "testemail@emcasa.com",
             "phone" => "123321123",
             "message" => "this website is cool",
             "state" => "SP",
             "city" => "São Paulo",
             "neighborhood" => "Morumbi"
           } == json_response(conn, 200)["data"]["notifyWhenCovered"]

    assert notify_when_covered = Repo.get_by(NotifyWhenCovered, name: "Mah Name")
    assert "testemail@emcasa.com" == notify_when_covered.email
    assert "123321123" == notify_when_covered.phone
    assert "this website is cool" == notify_when_covered.message
    assert "SP" == notify_when_covered.state
    assert "São Paulo" == notify_when_covered.city
    assert "Morumbi" == notify_when_covered.neighborhood
  end
end
