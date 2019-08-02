defmodule ReWeb.GraphQL.Interests.PriceSuggestions.QueryTest do
  use ReWeb.ConnCase

  alias ReWeb.AbsintheHelpers

  import Re.Factory
  import ExUnit.CaptureLog
  import Mockery
  import Re.CustomAssertion

  alias Re.{
    PriceSuggestions.Request,
    Repo
  }

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    user_user = insert(:user, email: "user@email.com", role: "user")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")

    {:ok,
     unauthenticated_conn: conn,
     user_user: user_user,
     user_conn: login_as(conn, user_user),
     admin_conn: login_as(conn, admin_user),
     admin_user: admin_user}
  end

  describe "priceSuggestionRequest" do
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

    test "anonymous should not request price suggestion", %{unauthenticated_conn: conn} do
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

      assert [%{"code" => 401, "message" => "Unauthorized"}] = json_response(conn, 200)["errors"]

      refute Repo.get_by(Request, name: "Mah Name")
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

    test "nameless anonymous should not request price suggestions", %{unauthenticated_conn: conn} do
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

      assert [%{"code" => 401, "message" => "Unauthorized"}] = json_response(conn, 200)["errors"]

      refute Repo.one(Request)
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
               post(
                 conn,
                 "/graphql_api",
                 AbsintheHelpers.mutation_wrapper(mutation, @invalid_variables)
               )
             end) =~ ":invalid_input in priceteller"

      assert request = Repo.get_by(Request, name: "Mah Name")
      assert request.user_id == user.id
      refute request.suggested_price
    end

    @tag capture_log: true
    test "handle priceteller timeout", %{user_conn: conn} do
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

      assert json_response(conn, 200)["data"]["requestPriceSuggestion"]

      assert request = Repo.get_by(Request, name: "Mah Name")
      refute request.suggested_price
    end
  end

  describe "priceSuggestion" do
    @variables %{
      "input" => %{
        "area" => 80,
        "rooms" => 2,
        "bathrooms" => 2,
        "garageSpots" => 2,
        "suites" => 1,
        "type" => "Apartamento",
        "maintenanceFee" => 300.00,
        "address" => %{
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
    }

    @invalid_variables %{
      "input" => %{
        "area" => 80,
        "rooms" => 2,
        "bathrooms" => 2,
        "garageSpots" => 2,
        "suites" => -1,
        "type" => "invalid",
        "maintenanceFee" => 0.0,
        "address" => %{
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
    }

    @query """
      query priceSuggestion ($input: PriceSuggestionInput!) {
        priceSuggestion(input: $input) {
          listingPrice
          listingPriceRounded
          salePrice
          salePriceRounded
          listingAveragePricePerSqrMeter
          listingPriceErrorQ90Max
          listingPriceErrorQ90Min
          listingPricePerSqrMeter
        }
      }
    """

    test "anonymous should not request price suggestion", %{unauthenticated_conn: conn} do
      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           body:
             "{\"sale_price_rounded\":24195.0,\"sale_price\":24195.791,\"listing_price_rounded\":26279.0,\"listing_price\":26279.915,\"listing_price_error_q90_min\":25200.0,\"listing_price_error_q90_max\":28544.0,\"listing_price_per_sqr_meter\":560.0,\"listing_average_price_per_sqr_meter\":610.0}"
         }}
      )

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@query, @variables))

      assert [%{"code" => 401, "message" => "Unauthorized"}] = json_response(conn, 200)["errors"]
    end

    test "user should not request price suggestion", %{user_conn: conn} do
      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           body:
             "{\"sale_price_rounded\":24195.0,\"sale_price\":24195.791,\"listing_price_rounded\":26279.0,\"listing_price\":26279.915,\"listing_price_error_q90_min\":25200.0,\"listing_price_error_q90_max\":28544.0,\"listing_price_per_sqr_meter\":560.0,\"listing_average_price_per_sqr_meter\":610.0}"
         }}
      )

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@query, @variables))

      assert [%{"code" => 403, "message" => "Forbidden"}] = json_response(conn, 200)["errors"]
    end

    test "admin should request price suggestion", %{admin_conn: conn} do
      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           body:
             "{\"sale_price_rounded\":24195.0,\"sale_price\":24195.791,\"listing_price_rounded\": 26279.0,\"listing_price\":26279.915,\"listing_price_error_q90_min\":25200.0,\"listing_price_error_q90_max\":28544.0,\"listing_price_per_sqr_meter\":560.0,\"listing_average_price_per_sqr_meter\":610.0}"
         }}
      )

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@query, @variables))

      assert %{
               "listingPrice" => 26279.915,
               "listingPriceRounded" => 26279.0,
               "salePrice" => 24195.791,
               "salePriceRounded" => 24195.0,
               "listingPriceErrorQ90Max" => 28544.0,
               "listingPriceErrorQ90Min" => 25200.0,
               "listingPricePerSqrMeter" => 560.0,
               "listingAveragePricePerSqrMeter" => 610.0
             } == json_response(conn, 200)["data"]["priceSuggestion"]
    end

    @tag capture_log: true
    test "admin should get nil price suggestion when parameters are not completly filled", %{
      admin_conn: conn
    } do
      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           body:
             "{\"sale_price_rounded\":24195.0,\"sale_price\":24195.791,\"listing_price_rounded\":26279.0,\"listing_price\":26279.915}"
         }}
      )

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@query, @invalid_variables))

      assert_mapper_match(
        [
          %{"message" => "suites: must be greater than or equal to 0"},
          %{"message" => "type: is invalid"}
        ],
        json_response(conn, 200)["errors"],
        &map_message/1
      )
    end

    @tag capture_log: true
    test "handle priceteller timeout", %{admin_conn: conn} do
      mock(HTTPoison, :post, {:error, %{reason: :timeout}})

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(@query, @variables))

      assert [%{"code" => 408, "message" => "Timeout"}] = json_response(conn, 200)["errors"]
    end
  end

  defp map_message(items), do: Enum.map(items, & &1["message"])
end
