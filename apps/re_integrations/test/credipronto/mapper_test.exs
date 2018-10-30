defmodule ReIntegrations.Credipronto.MapperTest do
  use ExUnit.Case

  alias ReIntegrations.Credipronto.Mapper

  describe "query_out/1" do
    test "should map simulation query to API format" do
      assert %{
               mutuario: "PF",
               data_nascimento: "01/05/1987",
               incluir_co: "N",
               renda_liquida: "19.000,00",
               renda_liquida_co: "",
               data_nascimento_co: "",
               tipo_produto: "F",
               tipo_imovel: "R",
               valor_imovel: "340.000,00",
               seguradora: "itau",
               amortizacao: "S",
               valor_financiavel: "278.800,00",
               tarifa_avaliacao: "3.300,00",
               prazo: "360",
               calcular_tr: "N",
               valor_itbi: "2.130,00",
               juros_anual: "10.5000000000",
               juros_anual_home_equity: "21.0000000000",
               rating: "2",
               somar: "S"
             } ==
               Mapper.query_out(%{
                 mutuary: "PF",
                 birthday: ~D[1987-05-01],
                 include_coparticipant: false,
                 net_income: Decimal.new(19_000),
                 net_income_coparticipant: nil,
                 birthday_coparticipant: nil,
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
                 home_equity_annual_interest: 21.0,
                 rating: 2,
                 sum: true
               })
    end
  end

  describe "payload_in/1" do
    test "should map payload" do
      assert %{cem: "10,8%", cet: "11,3%"} ==
               Mapper.payload_in(%{"cem" => "10,8%", "cet" => "11,3%"})
    end
  end
end
