defmodule ReWeb.GraphQL.SellerLeads.MutationTest do
  use ReWeb.{AbsintheAssertions, ConnCase}

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    price_request = insert(:price_suggestion_request)

    {
      :ok,
      unauthenticated_conn: conn,
      admin_conn: login_as(conn, admin_user),
      user_conn: login_as(conn, user_user),
      price_request: price_request
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

    test "user should add seller lead without priceRequestId", %{
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

      assert %{"siteSellerLeadCreate" => seller_lead} = json_response(conn, 200)["data"]

      assert seller_lead["uuid"]
      assert seller_lead["complement"] == "100"
      assert seller_lead["type"] == "Apartamento"
      assert seller_lead["price"] == 800_000
      assert seller_lead["maintenanceFee"] == 100.00
      assert seller_lead["suites"] == 2
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
end
