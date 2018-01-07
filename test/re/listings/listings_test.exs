defmodule Re.ListingsTest do
  use Re.ModelCase

  alias Re.{
    Listings
  }

  import Re.Factory

  describe "all/1" do
    test "should filter by max/min price" do
      laranjeiras = insert(:address, street: "astreet", neighborhood: "Laranjeiras")
      leblon = insert(:address, street: "anotherstreet", neighborhood: "Leblon")
      botafogo = insert(:address, street: "onemorestreet", neighborhood: "Botafogo")
      %{id: id1} = insert(:listing, price: 100, area: 40, rooms: 4, score: 4, address_id: laranjeiras.id)
      %{id: id2} = insert(:listing, price: 110, area: 60, rooms: 3, score: 3, address_id: leblon.id)
      %{id: id3} = insert(:listing, price: 90, area: 50, rooms: 3, score: 2, address_id: botafogo.id)

      assert [%{id: ^id1}, %{id: ^id3}] = Listings.all(%{"max_price" => 105})
      assert [%{id: ^id1}, %{id: ^id2}] = Listings.all(%{"min_price" => 95})
      assert [%{id: ^id2}, %{id: ^id3}] = Listings.all(%{"rooms" => 3})
      assert [%{id: ^id1}, %{id: ^id3}] = Listings.all(%{"max_area" => 55})
      assert [%{id: ^id1}, %{id: ^id2}] = Listings.all(%{"neighborhoods" => ["Laranjeiras", "Leblon"]})
    end
  end

  describe "paginated/1" do
    test "should return paginated result" do
      insert_list(3, :listing)

      page = Listings.paginated(%{page_size: 2, page: 1})
      assert [_, _] = page.entries
      assert 2 == page.page_size
      assert 2 == page.total_pages
      assert 3 == page.total_entries

      page = Listings.paginated(%{page_size: 2, page: 2})
      assert [_] = page.entries
      assert 2 == page.page_size
      assert 2 == page.total_pages
      assert 3 == page.total_entries
    end
  end

end
