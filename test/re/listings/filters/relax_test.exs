defmodule Re.Listings.Filters.RelaxTest do
  use Re.ModelCase

  alias Re.Listings.Filters.Relax

  describe "price/1" do
    test "max price" do
      assert %{max_price: 1_100_000} = Relax.price(%{max_price: 1_000_000})
    end

    test "min price" do
      assert %{min_price: 900_000} = Relax.price(%{min_price: 1_000_000})
    end

    test "min and max price" do
      assert %{min_price: 900_000, max_price: 2_200_000} = Relax.price(%{min_price: 1_000_000, max_price: 2_000_000})
    end

    test "nil min price" do
      assert %{max_price: 2_200_000} = Relax.price(%{min_price: nil, max_price: 2_000_000})
    end

    test "nil max price" do
      assert %{min_price: 900_000} = Relax.price(%{min_price: 1_000_000, max_price: nil})
    end
  end
end
