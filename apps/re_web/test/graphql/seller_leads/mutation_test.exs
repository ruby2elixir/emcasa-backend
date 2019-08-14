defmodule ReWeb.GraphQL.SellerLeads.MutationTest do
  use ReWeb.{AbsintheAssertions, ConnCase}

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user", type: "property_owner")
    broker_user = insert(:user, email: "user@email.com", role: "user", type: "partner_broker")

    price_request = insert(:price_suggestion_request)

    address = build(:address)

    {
      :ok,
      unauthenticated_conn: conn,
      admin_conn: login_as(conn, admin_user),
      user_conn: login_as(conn, user_user),
      broker_conn: login_as(conn, broker_user),
      price_request: price_request,
      address: address
    }
  end

  describe "create_site/2" do
    @create_mutation """
      mutation SiteSellerLeadCreate ($input: SiteSellerLeadInput!) {
        siteSellerLeadCreate(input: $input) {
          uuid
          complement
          type
          price
          maintenanceFee
          suites
        }
      }
    """

    test "admin should add seller lead", %{
      admin_conn: conn,
      price_request: price_request
    } do
      variables = %{
        "input" => %{
          "complement" => "100",
          "type" => "Apartamento",
          "maintenance_fee" => 100.00,
          "suites" => 2,
          "price" => 800_000,
          "priceRequestId" => price_request.id
        }
      }

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@create_mutation, variables))

      assert %{"siteSellerLeadCreate" => seller_lead} = json_response(conn, 200)["data"]

      assert seller_lead["uuid"]
      assert seller_lead["complement"] == "100"
      assert seller_lead["type"] == "Apartamento"
      assert seller_lead["price"] == 800_000
      assert seller_lead["maintenanceFee"] == 100.00
      assert seller_lead["suites"] == 2
    end

    test "user should add seller lead", %{
      user_conn: conn,
      price_request: price_request
    } do
      variables = %{
        "input" => %{
          "complement" => "100",
          "type" => "Apartamento",
          "maintenance_fee" => 100.00,
          "suites" => 2,
          "price" => 800_000,
          "priceRequestId" => price_request.id
        }
      }

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@create_mutation, variables))

      assert %{"siteSellerLeadCreate" => seller_lead} = json_response(conn, 200)["data"]

      assert seller_lead["uuid"]
      assert seller_lead["complement"] == "100"
      assert seller_lead["type"] == "Apartamento"
      assert seller_lead["price"] == 800_000
      assert seller_lead["maintenanceFee"] == 100.00
      assert seller_lead["suites"] == 2
    end

    test "user should not add seller lead without priceRequestId", %{
      user_conn: conn
    } do
      variables = %{
        "input" => %{
          "complement" => "100",
          "type" => "Apartamento",
          "maintenance_fee" => 100.00,
          "suites" => 2,
          "price" => 800_000
        }
      }

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@create_mutation, variables))

      assert [
               %{
                 "locations" => [%{"column" => 26, "line" => 2}],
                 "message" =>
                   "Argument \"input\" has invalid value $input.\nIn field \"priceRequestId\": Expected type \"ID!\", found null."
               }
             ] = json_response(conn, 200)["errors"]
    end

    test "anonymous should not add seller lead", %{
      unauthenticated_conn: conn,
      price_request: price_request
    } do
      variables = %{
        "input" => %{
          "complement" => "100",
          "type" => "Apartamento",
          "maintenance_fee" => 100.00,
          "suites" => 2,
          "price" => 800_000,
          "priceRequestId" => price_request.id
        }
      }

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@create_mutation, variables))

      assert %{"siteSellerLeadCreate" => nil} = json_response(conn, 200)["data"]

      assert_unauthorized_response(json_response(conn, 200))
    end
  end

  describe "create_broker/2" do
    @create_mutation """
      mutation BrokerSellerLeadCreate($input: BrokerSellerLeadInput!) {
        brokerSellerLeadCreate(input: $input) {
          uuid
        }
      }
    """
    test "admin should add broker lead", %{
      admin_conn: conn,
      address: address
    } do
      variables = %{
        "input" => %{
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
          "owner" => %{
            "email" => "a@a.com",
            "phone" => "+5599999999999",
            "name" => "Suzana Vieira"
           },
          "utm" => %{
            "campaign" => "facebook"
           },
          "type" => "Apartamento"
        }
      }
      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@create_mutation, variables))

      assert %{"brokerSellerLeadCreate" =>  uuid} = json_response(conn, 200)["data"]
    end

    test "property owner user should add broker lead", %{
      user_conn: conn,
      address: address
    } do
      variables = %{
        "input" => %{
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
          "owner" => %{
            "email" => "a@a.com",
            "phone" => "+5599999999999",
            "name" => "Suzana Vieira"
          },
          "type" => "Apartamento"
        }
      }
      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@create_mutation, variables))

      assert %{"brokerSellerLeadCreate" =>  uuid} = json_response(conn, 200)["data"]
    end

    test "anonymous user should not add broker lead", %{
      unauthenticated_conn: conn,
      address: address
    } do
      variables = %{
        "input" => %{
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
          "owner" => %{
            "email" => "a@a.com",
            "phone" => "+5599999999999",
            "name" => "Suzana Vieira"
          },
          "type" => "Apartamento"
        }
      }
      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@create_mutation, variables))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end

    test "broker user should add broker lead", %{
      broker_conn: conn,
      address: address
    } do
      variables = %{
        "input" => %{
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
          "owner" => %{
            "email" => "a@a.com",
            "phone" => "+5599999999999",
            "name" => "Suzana Vieira"
          },
          "type" => "Apartamento"
        }
      }
      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@create_mutation, variables))

      assert %{"brokerSellerLeadCreate" =>  uuid} = json_response(conn, 200)["data"]
    end

    test "broker user should not add broker lead with missing required fields", %{
      broker_conn: conn,
      address: address
    } do
      variables = %{
        "input" => %{
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
          "owner" => %{
            "phone" => "+5599999999999",
          },
          "type" => "Apartamento"
        }
      }
      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@create_mutation, variables))

      assert json_response(conn, 200)["errors"]
    end
  end
end
