defmodule Re.ListingsTest do
  use Re.ModelCase

  alias Re.{
    Listings
  }

  import Re.Factory

  describe "all/1" do
    test "should filter by max/min price" do
      %{id: id1} = insert(:listing, price: 100, area: 40, rooms: 4, score: 4)
      %{id: id2} = insert(:listing, price: 110, area: 60, rooms: 3, score: 3)
      %{id: id3} = insert(:listing, price: 90, area: 50, rooms: 3, score: 2)

      assert [%{id: ^id1}, %{id: ^id3}] = Listings.all(%{"max_price" => 105})
      assert [%{id: ^id1}, %{id: ^id2}] = Listings.all(%{"min_price" => 95})
      assert [%{id: ^id2}, %{id: ^id3}] = Listings.all(%{"rooms" => 3})
      assert [%{id: ^id1}, %{id: ^id3}] = Listings.all(%{"max_area" => 55})
      assert [%{id: ^id2}, %{id: ^id3}] = Listings.all(%{"min_area" => 45})
    end
  end

end
