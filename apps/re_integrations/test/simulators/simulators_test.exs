defmodule ReIntegrations.SimulatorsTest do
  use ExUnit.Case
  use Mockery

  alias ReIntegrations.Simulators

  describe "simulate/1" do
    @uri %URI{
      authority: "www.emcasa.com",
      host: "www.emcasa.com",
      path: "/simulator",
      port: 80,
      query:
        "account_id=test_account_id&amortizacao=S&calcular_tr=N&data_nascimento=22%2F05%2F1987&incluir_co=N&juros_anual=10.5000000000&juros_anual_home_equity=21.5000000000&mutuario=PF&prazo=360&rating=2&renda_liquida=19.000%2C00&seguradora=itau&somar=S&tarifa_avaliacao=3.300%2C00&tipo_imovel=R&tipo_produto=F&valor_financiavel=278.800%2C00&valor_imovel=340.000%2C00&valor_itbi=2.130%2C00",
      scheme: "http"
    }

    test "should make valid request do API" do
      mock(HTTPoison, :get, {:ok, %{body: "{\"cem\":\"10,8%\",\"cet\":\"11,3%\"}"}})

      assert {:ok,
              %{
                cem: "10,8%",
                cet: "11,3%"
              }} ==
               Simulators.simulate(%{
                 mutuary: "PF",
                 birthday: ~D[1987-05-22],
                 include_coparticipant: false,
                 net_income: Decimal.new(19_000),
                 product_type: "F",
                 listing_type: "R",
                 listing_price: Decimal.new(340_000),
                 insurer: "itau",
                 amortization: true,
                 fundable_value: Decimal.new(278_800),
                 evaluation_rate: Decimal.new(3_300),
                 term: 360,
                 calculate_tr: false,
                 itbi_value: Decimal.new(2_130),
                 annual_interest: 10.5,
                 home_equity_annual_interest: 21.5,
                 rating: 2,
                 sum: true
               })

      uri = @uri

      assert_called(HTTPoison, :get, [^uri, [], [follow_redirect: true]])
    end
  end
end
