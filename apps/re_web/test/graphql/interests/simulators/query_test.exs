defmodule ReWeb.GraphQL.Interests.Simulators.QueryTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok,
     unauthenticated_conn: conn,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user)}
  end

  @variables %{
    "input" => %{
      "mutuary" => "PF",
      "birthday" => "1987-05-22",
      "includeCoparticipant" => false,
      "netIncome" => "19000.00",
      "netIncomeCoparticipant" => nil,
      "birthdayCoparticipant" => nil,
      "productType" => "F",
      "listingType" => "R",
      "listingPrice" => "340000.00",
      "insurer" => "itau",
      "amortization" => true,
      "fundableValue" => "278800.00",
      "evaluationRate" => "3300.00",
      "term" => 360,
      "calculateTr" => false,
      "itbiValue" => "2130.00",
      "annualInterest" => 10.5,
      "homeEquityAnnualInterest" => 21.5,
      "sum" => true
    }
  }

  test "admin should request simulation", %{admin_conn: conn} do


    query = """
      query Simulate($input: SimulationRequest!) {
        simulate(input: $input) {
          cem
          cet
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, @variables))

    assert %{"cem" => "10,8%",
             "cet" => "11,3%"}
             == json_response(conn, 200)["data"]["simulate"]
  end

  test "user should request simulation", %{user_conn: conn} do


    query = """
      query Simulate($input: SimulationRequest!) {
        simulate(input: $input) {
          cem
          cet
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, @variables))

    assert %{"cem" => "10,8%",
             "cet" => "11,3%"}
             == json_response(conn, 200)["data"]["simulate"]
  end

  test "anonymous should not request simulation", %{unauthenticated_conn: conn} do


    query = """
      query Simulate($input: SimulationRequest!) {
        simulate(input: $input) {
          cem
          cet
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, @variables))

    assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
  end
end
