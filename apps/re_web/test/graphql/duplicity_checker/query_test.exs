defmodule ReWeb.GraphQL.DuplicityChecker.QueryTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    address = build(:address)

    {:ok,
     unauthenticated_conn: conn,
     address: address,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user)}
  end

  describe "check_duplicity" do
    @check_duplicity_query """
      query CheckDuplicity (
        $address: AddressInput!,
        $complement: String
      ){
        checkDuplicity (
          address: $address,
          complement: $complement
        )
      }
    """

    test "admin should query check_duplicity", %{admin_conn: conn, address: address} do
      variables = %{
        "address" => %{
          "city" => address.city,
          "state" => address.state,
          "lat" => address.lat,
          "lng" => address.lng,
          "neighborhood" => address.neighborhood,
          "street" => address.street,
          "streetNumber" => address.street_number,
          "postalCode" => address.postal_code
        }
      }

      conn =
        post(
          conn,
          "/graphql_api",
          AbsintheHelpers.query_wrapper(@check_duplicity_query, variables)
        )

      assert false == json_response(conn, 200)["data"]["checkDuplicity"]
    end

    test "user should query check_duplicity", %{user_conn: conn, address: address} do
      variables = %{
        "address" => %{
          "city" => address.city,
          "state" => address.state,
          "lat" => address.lat,
          "lng" => address.lng,
          "neighborhood" => address.neighborhood,
          "street" => address.street,
          "streetNumber" => address.street_number,
          "postalCode" => address.postal_code
        }
      }

      conn =
        post(
          conn,
          "/graphql_api",
          AbsintheHelpers.query_wrapper(@check_duplicity_query, variables)
        )

      assert false == json_response(conn, 200)["data"]["checkDuplicity"]
    end

    test "anonymous user should not query check_duplicity", %{
      unauthenticated_conn: conn,
      address: address
    } do
      variables = %{
        "address" => %{
          "city" => address.city,
          "state" => address.state,
          "lat" => address.lat,
          "lng" => address.lng,
          "neighborhood" => address.neighborhood,
          "street" => address.street,
          "streetNumber" => address.street_number,
          "postalCode" => address.postal_code
        }
      }

      conn =
        post(
          conn,
          "/graphql_api",
          AbsintheHelpers.query_wrapper(@check_duplicity_query, variables)
        )

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end

    test "should be true when for the input there is an address and a complement for a listing",
         %{user_conn: conn} do
      address = insert(:address)
      insert(:listing, address: address, complement: "Bloco 3 - Apto 200")

      variables = %{
        "address" => %{
          "city" => address.city,
          "state" => address.state,
          "lat" => address.lat,
          "lng" => address.lng,
          "neighborhood" => address.neighborhood,
          "street" => address.street,
          "streetNumber" => address.street_number,
          "postalCode" => address.postal_code
        },
        "complement" => "Apartamento 200, B3"
      }

      conn =
        post(
          conn,
          "/graphql_api",
          AbsintheHelpers.query_wrapper(@check_duplicity_query, variables)
        )

      assert true == json_response(conn, 200)["data"]["checkDuplicity"]
    end

    test "should be false when for the input there is an address and but not for the same complement for a listing",
         %{user_conn: conn} do
      address = insert(:address)
      insert(:listing, address: address, complement: "Bloco 3 - Apto 200")

      variables = %{
        "address" => %{
          "city" => address.city,
          "state" => address.state,
          "lat" => address.lat,
          "lng" => address.lng,
          "neighborhood" => address.neighborhood,
          "street" => address.street,
          "streetNumber" => address.street_number,
          "postalCode" => address.postal_code
        },
        "complement" => "Apartamento 400"
      }

      conn =
        post(
          conn,
          "/graphql_api",
          AbsintheHelpers.query_wrapper(@check_duplicity_query, variables)
        )

      assert false == json_response(conn, 200)["data"]["checkDuplicity"]
    end

    test "should be true when for the input there is an address and complement is nil for a listing",
         %{user_conn: conn} do
      address = insert(:address)
      insert(:listing, address: address, complement: nil)

      variables = %{
        "address" => %{
          "city" => address.city,
          "state" => address.state,
          "lat" => address.lat,
          "lng" => address.lng,
          "neighborhood" => address.neighborhood,
          "street" => address.street,
          "streetNumber" => address.street_number,
          "postalCode" => address.postal_code
        }
      }

      conn =
        post(
          conn,
          "/graphql_api",
          AbsintheHelpers.query_wrapper(@check_duplicity_query, variables)
        )

      assert true == json_response(conn, 200)["data"]["checkDuplicity"]
    end
  end
end
