defmodule ReWeb.GraphQL.Interests.Simulators.QueryTest do
  use ReWeb.ConnCase
  use Mockery

  import Re.Factory

  alias ReWeb.AbsintheHelpers

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

  @uri %URI{
    authority: "www.emcasa.com",
    fragment: nil,
    host: "www.emcasa.com",
    path: "/simulator",
    port: 80,
    query:
      "account_id=test_account_id&amortizacao=S&calcular_tr=N&data_nascimento=22%2F05%2F1987&data_nascimento_co=&incluir_co=N&juros_anual=10.5000000000&juros_anual_home_equity=21.5000000000&mutuario=PF&prazo=360&renda_liquida=19.000%2C00&renda_liquida_co=&seguradora=itau&somar=S&tarifa_avaliacao=3.300%2C00&tipo_imovel=R&tipo_produto=F&valor_financiavel=278.800%2C00&valor_imovel=340.000%2C00&valor_itbi=2.130%2C00",
    scheme: "http",
    userinfo: nil
  }

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok,
     unauthenticated_conn: conn,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user)}
  end

  test "admin should request simulation", %{admin_conn: conn} do
    mock(HTTPoison, :get, {:ok, %{status_code: 200, body: ~s({"cem":"10,8%","cet":"11,3%"})}})

    query = """
      query Simulate($input: SimulationRequest!) {
        simulate(input: $input) {
          cem
          cet
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, @variables))

    uri = @uri

    assert %{"cem" => "10,8%", "cet" => "11,3%"} == json_response(conn, 200)["data"]["simulate"]
    assert_called(HTTPoison, :get, [^uri, [], [follow_redirect: true]])
  end

  test "user should request simulation", %{user_conn: conn} do
    mock(HTTPoison, :get, {:ok, %{status_code: 200, body: ~s({"cem":"10,8%","cet":"11,3%"})}})

    query = """
      query Simulate($input: SimulationRequest!) {
        simulate(input: $input) {
          cem
          cet
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, @variables))

    uri = @uri

    assert %{"cem" => "10,8%", "cet" => "11,3%"} == json_response(conn, 200)["data"]["simulate"]
    assert_called(HTTPoison, :get, [^uri, [], [follow_redirect: true]])
  end

  test "anonymous should not request simulation", %{unauthenticated_conn: conn} do
    mock(HTTPoison, :get, {:ok, %{status_code: 200, body: ~s({"cem":"10,8%","cet":"11,3%"})}})

    query = """
      query Simulate($input: SimulationRequest!) {
        simulate(input: $input) {
          cem
          cet
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, @variables))

    uri = @uri

    assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    refute_called(HTTPoison, :get, [^uri, [], [follow_redirect: true]])
  end
end
