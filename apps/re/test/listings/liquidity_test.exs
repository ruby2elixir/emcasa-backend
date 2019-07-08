defmodule Re.Listings.LiquidityTest do
  use Re.ModelCase

  alias Re.Listings.Liquidity

  import Re.Factory

  @default_case -1

  describe "calculated/1" do
    @tag dev: true
    test "should return zero when price and price_suggestion are the same" do
      assert 0 == Liquidity.calculate(1_000_000, 1_000_000)
    end

    @tag dev: true
    test "should return positive value when price is lower price_suggestion" do
      assert 0 < Liquidity.calculate(900_000, 1_000_000)
    end

    @tag dev: true
    test "should return negative value when price is lower price_suggestion" do
      assert 0 > Liquidity.calculate(1_000_000, 900_000)
    end

    @tag dev: true
    test "should return constant value when price zero" do
      assert @default_case == Liquidity.calculate(0, 1_000_000)
    end

    @tag dev: true
    test "should return constant value when suggested_price zero" do
      assert @default_case == Liquidity.calculate(1_000_000, 0)
    end

    @tag dev: true
    test "should return constant value when suggested_price is nil" do
      assert @default_case == Liquidity.calculate(1_000_000, nil)
    end
  end
end
