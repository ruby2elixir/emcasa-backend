defmodule ReWeb.GraphQL.Interests.PriceSuggestions.QueryTest do
  use ReWeb.ConnCase

  alias ReWeb.AbsintheHelpers

  import Re.Factory
  import ExUnit.CaptureLog
  import Mockery

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
    "suites" => 1,
    "type" => "Apartamento",
    "maintenanceFee" => 300.00,
    "isCovered" => true,
    "addressInput" => %{
      "street" => "street",
      "streetNumber" => "street_number",
      "neighborhood" => "neighborhood",
      "city" => "city",
      "state" => "ST",
      "postalCode" => "12345-123",
      "lat" => 10.10,
      "lng" => 10.10
    }
  }

  @invalid_variables %{
    "name" => "Mah Name",
    "email" => "testemail@emcasa.com",
    "area" => 80,
    "rooms" => 2,
    "bathrooms" => 2,
    "garageSpots" => 2,
    "suites" => -1,
    "type" => "invalid",
    "maintenanceFee" => nil,
    "isCovered" => true,
    "addressInput" => %{
      "street" => "street",
      "streetNumber" => "street_number",
      "neighborhood" => "neighborhood",
      "city" => "city",
      "state" => "ST",
      "postalCode" => "12345-123",
      "lat" => 10.10,
      "lng" => 10.10
    }
  }

  test "anonymous should request price suggestion", %{unauthenticated_conn: conn} do
    mutation = """
      mutation RequestPriceSuggestion (
        $name: String!,
        $email: String!,
        $area: Int!,
        $rooms: Int!,
        $bathrooms: Int!,
        $garageSpots: Int!,
        $suites: Int,
        $type: String,
        $maintenanceFee: Float,
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
          suites: $suites
          type: $type
          maintenanceFee: $maintenanceFee
          isCovered: $isCovered
          address: $addressInput
        ) {
          suggestedPrice
        }
      }
    """

    mock(
      HTTPoison,
      :post,
      {:ok,
       %{
         body:
           "{\"sale_price_rounded\":24195.0,\"sale_price\":24195.791,\"listing_price_rounded\":26279.0,\"listing_price\":26279.915,\"listing_price_error_q90_min\":25200.0,\"listing_price_error_q90_max\":28544.0,\"listing_price_per_sqr_meter\":560.0,\"listing_average_price_per_sqr_meter\":610.0}"
       }}
    )

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, @variables))

    assert %{"suggestedPrice" => 26_279.0} ==
             json_response(conn, 200)["data"]["requestPriceSuggestion"]

    assert Repo.get_by(Request, name: "Mah Name")
  end

  test "user should request price suggestion", %{user_conn: conn, user_user: user} do
    mutation = """
      mutation RequestPriceSuggestion (
        $name: String!,
        $email: String!,
        $area: Int!,
        $rooms: Int!,
        $bathrooms: Int!,
        $garageSpots: Int!,
        $suites: Int,
        $type: String,
        $maintenanceFee: Float,
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
          suites: $suites
          type: $type
          maintenanceFee: $maintenanceFee
          isCovered: $isCovered
          address: $addressInput
        ) {
          suggestedPrice
        }
      }
    """

    mock(
      HTTPoison,
      :post,
      {:ok,
       %{
         body:
           "{\"sale_price_rounded\":24195.0,\"sale_price\":24195.791,\"listing_price_rounded\":26279.0,\"listing_price\":26279.915,\"listing_price_error_q90_min\":25200.0,\"listing_price_error_q90_max\":28544.0,\"listing_price_per_sqr_meter\":560.0,\"listing_average_price_per_sqr_meter\":610.0}"
       }}
    )

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, @variables))

    assert %{"suggestedPrice" => 26_279.0} ==
             json_response(conn, 200)["data"]["requestPriceSuggestion"]

    assert request = Repo.get_by(Request, name: "Mah Name")
    assert request.user_id == user.id
  end

  test "nameless anonymous user should request price suggestions", %{unauthenticated_conn: conn} do
    mutation = """
      mutation RequestPriceSuggestion (
        $email: String!,
        $area: Int!,
        $rooms: Int!,
        $bathrooms: Int!,
        $garageSpots: Int!,
        $suites: Int,
        $type: String,
        $maintenanceFee: Float,
        $isCovered: Boolean!,
        $addressInput: AddressInput!
        ) {
        requestPriceSuggestion(
          email: $email
          area: $area
          rooms: $rooms
          bathrooms: $bathrooms
          garageSpots: $garageSpots
          suites: $suites
          type: $type
          maintenanceFee: $maintenanceFee
          isCovered: $isCovered
          address: $addressInput
        ) {
          id
          name
          suggestedPrice
        }
      }
    """

    nameless_variables = Map.delete(@variables, "name")

    mock(
      HTTPoison,
      :post,
      {:ok,
       %{
         body:
           "{\"sale_price_rounded\":24195.0,\"sale_price\":24195.791,\"listing_price_rounded\":26279.0,\"listing_price\":26279.915,\"listing_price_error_q90_min\":25200.0,\"listing_price_error_q90_max\":28544.0,\"listing_price_per_sqr_meter\":560.0,\"listing_average_price_per_sqr_meter\":610.0}"
       }}
    )

    conn =
      post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, nameless_variables))

    %{"suggestedPrice" => suggested_price, "id" => id, "name" => name} =
      json_response(conn, 200)["data"]["requestPriceSuggestion"]

    assert 26_279.0 == suggested_price

    refute name

    assert Repo.get_by(Request, id: id)
  end

  test "user should get nil price suggestion when parameters are not completly filled", %{
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
        $suites: Int,
        $type: String,
        $maintenanceFee: Float,
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
          suites: $suites
          type: $type
          maintenanceFee: $maintenanceFee
          isCovered: $isCovered
          address: $addressInput
        ) {
          suggestedPrice
        }
      }
    """

    mock(
      HTTPoison,
      :post,
      {:ok,
       %{
         body:
           "{\"sale_price_rounded\":24195.0,\"sale_price\":24195.791,\"listing_price_rounded\":26279.0,\"listing_price\":26279.915}"
       }}
    )

    assert capture_log(fn ->
             conn =
               post(
                 conn,
                 "/graphql_api",
                 AbsintheHelpers.mutation_wrapper(mutation, @invalid_variables)
               )

             assert [%{"code" => 422}, %{"code" => 422}] = json_response(conn, 200)["errors"]
           end) =~ ":invalid_input in priceteller"

    assert request = Repo.get_by(Request, name: "Mah Name")
    assert request.user_id == user.id
  end

  @tag capture_log: true
  test "handle priceteller timeout", %{unauthenticated_conn: conn} do
    mutation = """
      mutation RequestPriceSuggestion (
        $name: String!,
        $email: String!,
        $area: Int!,
        $rooms: Int!,
        $bathrooms: Int!,
        $garageSpots: Int!,
        $suites: Int,
        $type: String,
        $maintenanceFee: Float,
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
          suites: $suites
          type: $type
          maintenanceFee: $maintenanceFee
          isCovered: $isCovered
          address: $addressInput
        ) {
          suggestedPrice
        }
      }
    """

    mock(HTTPoison, :post, {:error, %{reason: :timeout}})

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, @variables))

    refute json_response(conn, 200)["data"]["requestPriceSuggestion"]

    assert [%{"message" => "Timeout", "code" => 408}] = json_response(conn, 200)["errors"]

    assert Repo.get_by(Request, name: "Mah Name")
  end
end
