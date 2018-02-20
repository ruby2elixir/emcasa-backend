defmodule Re.Listings.Filters.RelaxTest do
  use Re.ModelCase

  alias Re.Listings.Filters.Relax

  describe "price/1" do
    test "max price" do
      assert %{max_price: 1_100_000} = Relax.do_apply(:price, %{max_price: 1_000_000})
    end

    test "min price" do
      assert %{min_price: 900_000} = Relax.do_apply(:price, %{min_price: 1_000_000})
    end

    test "min and max price" do
      assert %{min_price: 900_000, max_price: 2_200_000} =
               Relax.do_apply(:price, %{min_price: 1_000_000, max_price: 2_000_000})
    end

    test "nil min price" do
      assert %{max_price: 2_200_000} =
               Relax.do_apply(:price, %{min_price: nil, max_price: 2_000_000})
    end

    test "nil max price" do
      assert %{min_price: 900_000} =
               Relax.do_apply(:price, %{min_price: 1_000_000, max_price: nil})
    end
  end

  describe "area/1" do
    test "max area" do
      assert %{max_area: 55} = Relax.do_apply(:area, %{max_area: 50})
    end

    test "min area" do
      assert %{min_area: 45} = Relax.do_apply(:area, %{min_area: 50})
    end

    test "min and max area" do
      assert %{min_area: 45, max_area: 110} =
               Relax.do_apply(:area, %{min_area: 50, max_area: 100})
    end

    test "nil min area" do
      assert %{max_area: 110} = Relax.do_apply(:area, %{min_area: nil, max_area: 100})
    end

    test "nil max area" do
      assert %{min_area: 45} = Relax.do_apply(:area, %{min_area: 50, max_area: nil})
    end
  end

  describe "room/1" do
    test "max room" do
      assert %{max_rooms: 4} = Relax.do_apply(:room, %{max_rooms: 3})
    end

    test "min room" do
      assert %{min_rooms: 2} = Relax.do_apply(:room, %{min_rooms: 3})
    end

    test "min and max room" do
      assert %{min_rooms: 2, max_rooms: 5} = Relax.do_apply(:room, %{min_rooms: 3, max_rooms: 4})
    end

    test "nil min room" do
      assert %{max_rooms: 4} = Relax.do_apply(:room, %{min_rooms: nil, max_rooms: 3})
    end

    test "nil max room" do
      assert %{min_rooms: 2} = Relax.do_apply(:room, %{min_rooms: 3, max_rooms: nil})
    end
  end
end
