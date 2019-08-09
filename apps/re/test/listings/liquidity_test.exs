defmodule Re.Listings.LiquidityTest do
  use Re.ModelCase

  alias Re.Listings.Liquidity

  @default_case nil

  describe "calculated/1" do
    test "should return zero when price and price_suggestion are the same" do
      assert 0 == Liquidity.calculate(1_000_000, 1_000_000)
    end

    test "should return positive value when price is lower than price_suggestion" do
      assert 0 < Liquidity.calculate(900_000, 1_000_000)
    end

    test "should return negative value when price is higher than price_suggestion" do
      assert 0 > Liquidity.calculate(1_000_000, 900_000)
    end

    test "should return constant value when price zero" do
      assert @default_case == Liquidity.calculate(0, 1_000_000)
    end

    test "should return constant value when suggested_price zero" do
      assert @default_case == Liquidity.calculate(1_000_000, 0)
    end

    test "should return constant value when suggested_price is nil" do
      assert @default_case == Liquidity.calculate(1_000_000, nil)
    end

    test "should return constant value when price is nil" do
      assert @default_case == Liquidity.calculate(nil, 1_000_000)
    end
  end

  describe "normalize_liquidity_ratio/1" do
    test "normalize nil liquidity to 0" do
      assert 0 == Liquidity.normalize_liquidity_ratio(nil)
    end

    test "normalize -0.75 or lower liquidity ratio to 0" do
      assert 0 == Liquidity.normalize_liquidity_ratio(-0.75)
      assert 0 == Liquidity.normalize_liquidity_ratio(-2.0)
    end

    test "normalize -0.6 or lower liquidity ratio to 1" do
      assert 1 == Liquidity.normalize_liquidity_ratio(-0.6)
      assert 1 == Liquidity.normalize_liquidity_ratio(-0.7)
    end

    test "normalize -0.45 or lower liquidity ratio to 2" do
      assert 2 == Liquidity.normalize_liquidity_ratio(-0.45)
      assert 2 == Liquidity.normalize_liquidity_ratio(-0.5)
    end

    test "normalize -0.3 or lower liquidity ratio to 3" do
      assert 3 == Liquidity.normalize_liquidity_ratio(-0.3)
      assert 3 == Liquidity.normalize_liquidity_ratio(-0.4)
    end

    test "normalize -0.14 or lower liquidity ratio to " do
      assert 4 == Liquidity.normalize_liquidity_ratio(-0.16)
      assert 4 == Liquidity.normalize_liquidity_ratio(-0.2)
    end

    test "normalize liquidity ratio beetween -0.15 and 0.15 to 5" do
      assert 5 == Liquidity.normalize_liquidity_ratio(-0.15)
      assert 5 == Liquidity.normalize_liquidity_ratio(0.0)
      assert 5 == Liquidity.normalize_liquidity_ratio(0.15)
    end

    test "normalize 0.3 or lower liquidity ratio to 6" do
      assert 6 == Liquidity.normalize_liquidity_ratio(0.3)
      assert 6 == Liquidity.normalize_liquidity_ratio(0.2)
    end

    test "normalize 0.45 or lower liquidity ratio to 7" do
      assert 7 == Liquidity.normalize_liquidity_ratio(0.45)
      assert 7 == Liquidity.normalize_liquidity_ratio(0.4)
    end

    test "normalize 0.6 or lower liquidity ratio to 8" do
      assert 8 == Liquidity.normalize_liquidity_ratio(0.6)
      assert 8 == Liquidity.normalize_liquidity_ratio(0.5)
    end

    test "normalize 0.75 or lower liquidity ratio to 9" do
      assert 9 == Liquidity.normalize_liquidity_ratio(0.75)
      assert 9 == Liquidity.normalize_liquidity_ratio(0.7)
    end

    test "normalize higher than 0.75 liquidity ratio to 10" do
      assert 10 == Liquidity.normalize_liquidity_ratio(0.76)
      assert 10 == Liquidity.normalize_liquidity_ratio(1.0)
    end
  end
end
