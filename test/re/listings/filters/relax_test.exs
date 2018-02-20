defmodule Re.Listings.Filters.RelaxTest do
  use Re.ModelCase

  alias Re.Listings.Filters.Relax

  describe "price/1" do
    test "max price" do
      assert %{max_price: 1_100_000} = Relax.apply(%{max_price: 1_000_000}, [:price])
    end

    test "min price" do
      assert %{min_price: 900_000} = Relax.apply(%{min_price: 1_000_000}, [:price])
    end

    test "min and max price" do
      assert %{min_price: 900_000, max_price: 2_200_000} =
               Relax.apply(%{min_price: 1_000_000, max_price: 2_000_000}, [:price])
    end

    test "nil min price" do
      assert %{max_price: 2_200_000} =
               Relax.apply(%{min_price: nil, max_price: 2_000_000}, [:price])
    end

    test "nil max price" do
      assert %{min_price: 900_000} =
               Relax.apply(%{min_price: 1_000_000, max_price: nil}, [:price])
    end
  end

  describe "area/1" do
    test "max area" do
      assert %{max_area: 55} = Relax.apply(%{max_area: 50}, [:area])
    end

    test "min area" do
      assert %{min_area: 45} = Relax.apply(%{min_area: 50}, [:area])
    end

    test "min and max area" do
      assert %{min_area: 45, max_area: 110} = Relax.apply(%{min_area: 50, max_area: 100}, [:area])
    end

    test "nil min area" do
      assert %{max_area: 110} = Relax.apply(%{min_area: nil, max_area: 100}, [:area])
    end

    test "nil max area" do
      assert %{min_area: 45} = Relax.apply(%{min_area: 50, max_area: nil}, [:area])
    end
  end

  describe "room/1" do
    test "max room" do
      assert %{max_rooms: 4} = Relax.apply(%{max_rooms: 3}, [:room])
    end

    test "min room" do
      assert %{min_rooms: 2} = Relax.apply(%{min_rooms: 3}, [:room])
    end

    test "min and max room" do
      assert %{min_rooms: 2, max_rooms: 5} = Relax.apply(%{min_rooms: 3, max_rooms: 4}, [:room])
    end

    test "nil min room" do
      assert %{max_rooms: 4} = Relax.apply(%{min_rooms: nil, max_rooms: 3}, [:room])
    end

    test "nil max room" do
      assert %{min_rooms: 2} = Relax.apply(%{min_rooms: 3, max_rooms: nil}, [:room])
    end
  end
end
