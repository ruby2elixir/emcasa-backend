defmodule ReWeb.GraphQL.BuyerLeads.MutationTest do
  use ReWeb.{AbsintheAssertions, ConnCase}

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {
      :ok,
      unauthenticated_conn: conn,
      admin_conn: login_as(conn, admin_user),
      user_conn: login_as(conn, user_user)
    }
  end

  describe "create_budget/2" do
    @create_mutation """
      mutation BudgetBuyerLeadCreate ($input: BudgetBuyerLeadInput!) {
        budgetBuyerLeadCreate(input: $input) {
          message
        }
      }
    """

    test "admin should add budget buyer lead", %{
      admin_conn: conn
    } do
      %{state: state, city: city, neighborhood: neighborhood, budget: budget} =
        params_for(:budget_buyer_lead)

      variables = %{
        "input" => %{
          "state" => state,
          "city" => city,
          "neighborhood" => neighborhood,
          "budget" => budget
        }
      }

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@create_mutation, variables))

      assert %{"budgetBuyerLeadCreate" => buyer_lead} = json_response(conn, 200)["data"]

      assert buyer_lead["message"] == "ok"
    end

    test "user should add budget buyer lead", %{
      user_conn: conn
    } do
      %{state: state, city: city, neighborhood: neighborhood, budget: budget} =
        params_for(:budget_buyer_lead)

      variables = %{
        "input" => %{
          "state" => state,
          "city" => city,
          "neighborhood" => neighborhood,
          "budget" => budget
        }
      }

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@create_mutation, variables))

      assert %{"budgetBuyerLeadCreate" => buyer_lead} = json_response(conn, 200)["data"]

      assert buyer_lead["message"] == "ok"
    end

    test "anonymous should add budget buyer lead", %{
      unauthenticated_conn: conn
    } do
      %{state: state, city: city, neighborhood: neighborhood, budget: budget} =
        params_for(:budget_buyer_lead)

      variables = %{
        "input" => %{
          "state" => state,
          "city" => city,
          "neighborhood" => neighborhood,
          "budget" => budget
        }
      }

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(@create_mutation, variables))

      assert %{"budgetBuyerLeadCreate" => nil} = json_response(conn, 200)["data"]

      assert_unauthorized_response(json_response(conn, 200))
    end
  end
end
