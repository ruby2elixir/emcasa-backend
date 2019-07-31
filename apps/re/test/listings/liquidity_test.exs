defmodule Re.Listings.LiquidityTest do
  use Re.ModelCase

  alias Re.Listings.Liquidity

  @default_case nil

  describe "calculated/1" do
    test "should return zero when price and price_suggestion are the same" do
      assert 0 == Liquidity.calculate(1_000_000, 1_000_000)
    end

    test "should return positive value when price is lower price_suggestion" do
      assert 0 < Liquidity.calculate(900_000, 1_000_000)
    end

    test "should return negative value when price is lower price_suggestion" do
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

    test "normalize -1 or lower liquidity ratio to 0" do
      assert 0 == Liquidity.normalize_liquidity_ratio(-1.0)
      assert 0 == Liquidity.normalize_liquidity_ratio(-2.0)
    end

    test "normalize -0.8 or lower liquidity ratio to 1" do
      assert 1 == Liquidity.normalize_liquidity_ratio(-0.8)
      assert 1 == Liquidity.normalize_liquidity_ratio(-0.9)
    end

    test "normalize -0.6 or lower liquidity ratio to 2" do
      assert 2 == Liquidity.normalize_liquidity_ratio(-0.6)
      assert 2 == Liquidity.normalize_liquidity_ratio(-0.7)
    end

    test "normalize -0.4 or lower liquidity ratio to 3" do
      assert 3 == Liquidity.normalize_liquidity_ratio(-0.4)
      assert 3 == Liquidity.normalize_liquidity_ratio(-0.5)
    end

    test "normalize liquidity ratio lower than -0.2 to 3" do
      assert 4 == Liquidity.normalize_liquidity_ratio(-0.3)
    end

    test "normalize liquidity ratio beetween -0.2 and 0.2 to 5" do
      assert 5 == Liquidity.normalize_liquidity_ratio(-0.2)
      assert 5 == Liquidity.normalize_liquidity_ratio(0.0)
      assert 5 == Liquidity.normalize_liquidity_ratio(0.2)
    end

    test "normalize 0.3 or lower liquidity ratio to 6" do
      assert 6 == Liquidity.normalize_liquidity_ratio(0.3)
    end

    test "normalize 0.4 or lower liquidity ratio to 7" do
      assert 7 == Liquidity.normalize_liquidity_ratio(0.4)
    end

    test "normalize 0.5 or lower liquidity ratio to 8" do
      assert 8 == Liquidity.normalize_liquidity_ratio(0.5)
    end

    test "normalize 0.6 or lower liquidity ratio to 9" do
      assert 9 == Liquidity.normalize_liquidity_ratio(0.6)
    end

    test "normalize 0.7 or lower liquidity ratio to 9" do
      assert 10 == Liquidity.normalize_liquidity_ratio(0.7)
      assert 10 == Liquidity.normalize_liquidity_ratio(1.0)
    end
  end
end
