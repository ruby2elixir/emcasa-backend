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

  describe "area/1" do
    test "max area" do
      assert %{max_area: 55} = Relax.area(%{max_area: 50})
    end

    test "min area" do
      assert %{min_area: 45} = Relax.area(%{min_area: 50})
    end

    test "min and max area" do
      assert %{min_area: 45, max_area: 110} = Relax.area(%{min_area: 50, max_area: 100})
    end

    test "nil min area" do
      assert %{max_area: 110} = Relax.area(%{min_area: nil, max_area: 100})
    end

    test "nil max area" do
      assert %{min_area: 45} = Relax.area(%{min_area: 50, max_area: nil})
    end
  end
end
