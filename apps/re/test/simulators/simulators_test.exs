defmodule Re.SimulatorsTest do
  use ExUnit.Case

  alias Re.Simulators

  describe "simulate/1" do
    test "should make valid request do API" do
      assert {:ok, %{
        "cem" => "10,8%",
        "cet" => "11,3%"
      }} == Simulators.simulate(%{
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
    end
  end


end
