defmodule Re.Listings.Filters.RelaxTest do
  use Re.ModelCase

  alias Re.Listings.Filters.Relax

  describe "price/1" do
    test "max price" do
      assert %{max_price: 1_100_000} = Relax.apply(%{max_price: 1_000_000})
    end

    test "min price" do
      assert %{min_price: 900_000} = Relax.apply(%{min_price: 1_000_000})
    end

    test "min and max price" do
      assert %{min_price: 900_000, max_price: 2_200_000} =
               Relax.apply(%{min_price: 1_000_000, max_price: 2_000_000})
    end

    test "nil min price" do
      assert %{max_price: 2_200_000} = Relax.apply(%{min_price: nil, max_price: 2_000_000})
    end

    test "nil max price" do
      assert %{min_price: 900_000} = Relax.apply(%{min_price: 1_000_000, max_price: nil})
    end
  end

  describe "area/1" do
    test "max area" do
      assert %{max_area: 55} = Relax.apply(%{max_area: 50})
    end

    test "min area" do
      assert %{min_area: 45} = Relax.apply(%{min_area: 50})
    end

    test "min and max area" do
      assert %{min_area: 45, max_area: 110} = Relax.apply(%{min_area: 50, max_area: 100})
    end

    test "nil min area" do
      assert %{max_area: 110} = Relax.apply(%{min_area: nil, max_area: 100})
    end

    test "nil max area" do
      assert %{min_area: 45} = Relax.apply(%{min_area: 50, max_area: nil})
    end
  end

  describe "room/1" do
    test "max room" do
      assert %{max_rooms: 4} = Relax.apply(%{max_rooms: 3})
    end

    test "min room" do
      assert %{min_rooms: 2} = Relax.apply(%{min_rooms: 3})
    end

    test "min and max room" do
      assert %{min_rooms: 2, max_rooms: 5} = Relax.apply(%{min_rooms: 3, max_rooms: 4})
    end

    test "nil min room" do
      assert %{max_rooms: 4} = Relax.apply(%{min_rooms: nil, max_rooms: 3})
    end

    test "nil max room" do
      assert %{min_rooms: 2} = Relax.apply(%{min_rooms: 3, max_rooms: nil})
    end
  end

  describe "neighborhoods/1" do
    test "one neighborhood" do
      assert %{neighborhoods: ["Humaitá", "Botafogo"]} =
               Relax.apply(%{neighborhoods: ["Botafogo"]})
    end

    test "multiple neighborhoods" do
      assert %{neighborhoods: ["Leblon", "Gávea", "Copacabana", "Ipanema"]} =
               Relax.apply(%{neighborhoods: ["Gávea", "Leblon", "Ipanema"]})
    end

    test "empty neighborhoods" do
      assert %{neighborhoods: []} = Relax.apply(%{neighborhoods: []})
    end

    test "nil neighborhoods" do
      assert %{} = Relax.apply(%{neighborhoods: nil})
    end
  end

  describe "garage_spots/1" do
    test "max garage_spots" do
      assert %{max_garage_spots: 4} = Relax.apply(%{max_garage_spots: 3})
    end

    test "min garage_spots" do
      assert %{min_garage_spots: 2} = Relax.apply(%{min_garage_spots: 3})
    end

    test "min and max garage_spots" do
      assert %{min_garage_spots: 2, max_garage_spots: 5} =
               Relax.apply(%{min_garage_spots: 3, max_garage_spots: 4})
    end

    test "nil min garage_spots" do
      assert %{max_garage_spots: 4} = Relax.apply(%{min_garage_spots: nil, max_garage_spots: 3})
    end

    test "nil max garage_spots" do
      assert %{min_garage_spots: 2} = Relax.apply(%{min_garage_spots: 3, max_garage_spots: nil})
    end
  end
end
