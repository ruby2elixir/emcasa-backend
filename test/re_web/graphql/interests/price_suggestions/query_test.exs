defmodule ReWeb.GraphQL.PriceSuggestions.QueryTest do
  use ReWeb.ConnCase

  alias ReWeb.AbsintheHelpers

  import Re.Factory

  alias Re.{
    PriceSuggestions.Request,
    Repo
  }

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok, unauthenticated_conn: conn, user_user: user_user, user_conn: login_as(conn, user_user)}
  end

  @request_price_suggestion_input """
      name: "Mah Name",
      email: "testemail@emcasa.com",
      area: 80,
      rooms: 2,
      bathrooms: 2,
      garage_spots: 2,
      isCovered: true,
      address: {
        street: "street",
        street_number: "street_number",
        neighborhood: "neighborhood",
        city: "city",
        state: "ST",
        postal_code: "postal_code",
        lat: 10.10,
        lng: 10.10
      }
  """

  test "anonymous should request price suggestion", %{unauthenticated_conn: conn} do
    insert(
      :factors,
      street: "street",
      intercept: 10.10,
      rooms: 123.321,
      area: 321.123,
      bathrooms: 111.222,
      garage_spots: 222.111
    )

    mutation = """
      mutation {
        requestPriceSuggestion(#{@request_price_suggestion_input}) {
          name
          email
          area
          rooms
          bathrooms
          garage_spots
          isCovered
          address {
            street
            street_number
            neighborhood
            city
            state
            postal_code
            lat
            lng
          }
          suggestedPrice
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert %{"requestPriceSuggestion" => %{"suggestedPrice" => 26_613.248}} =
             json_response(conn, 200)["data"]

    assert Repo.get_by(Request, name: "Mah Name")
  end

  test "user should request price suggestion", %{user_conn: conn, user_user: user} do
    insert(
      :factors,
      street: "street",
      intercept: 10.10,
      rooms: 123.321,
      area: 321.123,
      bathrooms: 111.222,
      garage_spots: 222.111
    )

    mutation = """
      mutation {
        requestPriceSuggestion(#{@request_price_suggestion_input}) {
          name
          email
          area
          rooms
          bathrooms
          garage_spots
          isCovered
          address {
            street
            street_number
            neighborhood
            city
            state
            postal_code
            lat
            lng
          }
          suggestedPrice
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert %{"requestPriceSuggestion" => %{"suggestedPrice" => 26_613.248}} =
             json_response(conn, 200)["data"]

    assert request = Repo.get_by(Request, name: "Mah Name")
    assert request.user_id == user.id
  end

  test "anonymous should request price suggestion when street is not covered", %{
    unauthenticated_conn: conn
  } do
    mutation = """
      mutation {
        requestPriceSuggestion(#{@request_price_suggestion_input}) {
          name
          email
          area
          rooms
          bathrooms
          garage_spots
          isCovered
          address {
            street
            street_number
            neighborhood
            city
            state
            postal_code
            lat
            lng
          }
          suggestedPrice
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert %{"requestPriceSuggestion" => %{"suggestedPrice" => nil}} =
             json_response(conn, 200)["data"]

    assert Repo.get_by(Request, name: "Mah Name")
  end

  test "user should request price suggestion when street is not covered", %{
    user_conn: conn,
    user_user: user
  } do
    mutation = """
      mutation {
        requestPriceSuggestion(#{@request_price_suggestion_input}) {
          name
          email
          area
          rooms
          bathrooms
          garage_spots
          isCovered
          address {
            street
            street_number
            neighborhood
            city
            state
            postal_code
            lat
            lng
          }
          suggestedPrice
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert %{"requestPriceSuggestion" => %{"suggestedPrice" => nil}} =
             json_response(conn, 200)["data"]

    assert request = Repo.get_by(Request, name: "Mah Name")
    assert request.user_id == user.id
  end
end
