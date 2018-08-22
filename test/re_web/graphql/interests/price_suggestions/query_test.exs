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

  @variables %{
      "name" => "Mah Name",
      "email" => "testemail@emcasa.com",
      "area" => 80,
      "rooms" => 2,
      "bathrooms" => 2,
      "garageSpots" => 2,
      "isCovered" => true,
      "addressInput" => %{
        "street" => "street",
        "streetNumber" => "street_number",
        "neighborhood" => "neighborhood",
        "city" => "city",
        "state" => "ST",
        "postalCode" => "postal_code",
        "lat" => 10.10,
        "lng" => 10.10
      }
  }

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
      mutation RequestPriceSuggestion (
        $name: String!,
        $email: String!,
        $area: Int!,
        $rooms: Int!,
        $bathrooms: Int!,
        $garageSpots: Int!,
        $isCovered: Boolean!,
        $addressInput: AddressInput!
        ) {
        requestPriceSuggestion(
          name: $name
          email: $email
          area: $area
          rooms: $rooms
          bathrooms: $bathrooms
          garageSpots: $garageSpots
          isCovered: $isCovered
          address: $addressInput
        ) {
          suggestedPrice
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, @variables))

    assert %{"suggestedPrice" => 26_613.248} ==
             json_response(conn, 200)["data"]["requestPriceSuggestion"]

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
      mutation RequestPriceSuggestion (
        $name: String!,
        $email: String!,
        $area: Int!,
        $rooms: Int!,
        $bathrooms: Int!,
        $garageSpots: Int!,
        $isCovered: Boolean!,
        $addressInput: AddressInput!
        ) {
        requestPriceSuggestion(
          name: $name
          email: $email
          area: $area
          rooms: $rooms
          bathrooms: $bathrooms
          garageSpots: $garageSpots
          isCovered: $isCovered
          address: $addressInput
        ) {
          suggestedPrice
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, @variables))

    assert %{"suggestedPrice" => 26_613.248} ==
             json_response(conn, 200)["data"]["requestPriceSuggestion"]

    assert request = Repo.get_by(Request, name: "Mah Name")
    assert request.user_id == user.id
  end

  test "anonymous should request price suggestion when street is not covered", %{
    unauthenticated_conn: conn
  } do
    mutation = """
      mutation RequestPriceSuggestion (
        $name: String!,
        $email: String!,
        $area: Int!,
        $rooms: Int!,
        $bathrooms: Int!,
        $garageSpots: Int!,
        $isCovered: Boolean!,
        $addressInput: AddressInput!
        ) {
        requestPriceSuggestion(
          name: $name
          email: $email
          area: $area
          rooms: $rooms
          bathrooms: $bathrooms
          garageSpots: $garageSpots
          isCovered: $isCovered
          address: $addressInput
        ) {
          suggestedPrice
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, @variables))

    assert %{"suggestedPrice" => nil} ==
             json_response(conn, 200)["data"]["requestPriceSuggestion"]

    assert Repo.get_by(Request, name: "Mah Name")
  end

  test "user should request price suggestion when street is not covered", %{
    user_conn: conn,
    user_user: user
  } do
    mutation = """
      mutation RequestPriceSuggestion (
        $name: String!,
        $email: String!,
        $area: Int!,
        $rooms: Int!,
        $bathrooms: Int!,
        $garageSpots: Int!,
        $isCovered: Boolean!,
        $addressInput: AddressInput!
        ) {
        requestPriceSuggestion(
          name: $name
          email: $email
          area: $area
          rooms: $rooms
          bathrooms: $bathrooms
          garageSpots: $garageSpots
          isCovered: $isCovered
          address: $addressInput
        ) {
          suggestedPrice
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, @variables))

    assert %{"suggestedPrice" => nil} ==
             json_response(conn, 200)["data"]["requestPriceSuggestion"]

    assert request = Repo.get_by(Request, name: "Mah Name")
    assert request.user_id == user.id
  end
end
