defmodule Re.ListingsTest do
  use Re.ModelCase

  alias Re.{
    Listing,
    Listings
  }

  import Re.Factory

  describe "all/1" do
    test "should filter by attributes" do
      laranjeiras =
        insert(
          :address,
          street: "astreet",
          neighborhood: "Laranjeiras",
          lat: -22.9675614,
          lng: -43.20261119999998
        )

      leblon =
        insert(
          :address,
          street: "anotherstreet",
          neighborhood: "Leblon",
          lat: -22.9461014,
          lng: -43.21675540000001
        )

      botafogo =
        insert(
          :address,
          street: "onemorestreet",
          neighborhood: "Botafogo",
          lat: -22.9961014,
          lng: -43.19675540000001
        )

      %{id: id1} =
        insert(
          :listing,
          price: 100,
          area: 40,
          rooms: 4,
          score: 4,
          address_id: laranjeiras.id,
          type: "Apartamento"
        )

      %{id: id2} =
        insert(
          :listing,
          price: 110,
          area: 60,
          rooms: 3,
          score: 3,
          address_id: leblon.id,
          type: "Apartamento"
        )

      %{id: id3} =
        insert(
          :listing,
          price: 90,
          area: 50,
          rooms: 3,
          score: 2,
          address_id: botafogo.id,
          type: "Casa"
        )

      assert %{entries: [%{id: ^id1}, %{id: ^id3}]} = Listings.paginated(%{"max_price" => 105})
      assert %{entries: [%{id: ^id1}, %{id: ^id2}]} = Listings.paginated(%{"min_price" => 95})
      assert %{entries: [%{id: ^id2}, %{id: ^id3}]} = Listings.paginated(%{"rooms" => 3})
      assert %{entries: [%{id: ^id2}, %{id: ^id3}]} = Listings.paginated(%{"max_rooms" => 3})
      assert %{entries: [%{id: ^id1}]} = Listings.paginated(%{"min_rooms" => 4})
      assert %{entries: [%{id: ^id1}, %{id: ^id3}]} = Listings.paginated(%{"max_area" => 55})

      assert %{entries: [%{id: ^id1}, %{id: ^id2}]} =
               Listings.paginated(%{"neighborhoods" => ["Laranjeiras", "Leblon"]})

      assert %{entries: [%{id: ^id1}, %{id: ^id2}]} =
               Listings.paginated(%{"types" => ["Apartamento"]})

      assert %{entries: [%{id: ^id1}, %{id: ^id3}]} = Listings.paginated(%{"max_lat" => -22.95})
      assert %{entries: [%{id: ^id1}, %{id: ^id2}]} = Listings.paginated(%{"min_lat" => -22.98})
      assert %{entries: [%{id: ^id1}, %{id: ^id2}]} = Listings.paginated(%{"max_lng" => -43.199})
      assert %{entries: [%{id: ^id1}, %{id: ^id3}]} = Listings.paginated(%{"min_lng" => -43.203})
    end

    test "should not filter for empty array" do
      laranjeiras = insert(:address, street: "astreet", neighborhood: "Laranjeiras")
      leblon = insert(:address, street: "anotherstreet", neighborhood: "Leblon")
      botafogo = insert(:address, street: "onemorestreet", neighborhood: "Botafogo")

      %{id: id1} = insert(:listing, score: 4, address_id: laranjeiras.id, type: "Apartamento")
      %{id: id2} = insert(:listing, score: 3, address_id: leblon.id, type: "Casa")
      %{id: id3} = insert(:listing, score: 2, address_id: botafogo.id, type: "Apartamento")

      assert %{entries: [%{id: ^id1}, %{id: ^id2}, %{id: ^id3}]} =
               Listings.paginated(%{"neighborhoods" => []})

      assert %{entries: [%{id: ^id1}, %{id: ^id2}, %{id: ^id3}]} =
               Listings.paginated(%{"types" => []})
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

  describe "delete/1" do
    test "should set is_active to false" do
      listing = insert(:listing)

      {:ok, listing} = Listings.delete(listing)
      refute listing.is_active
    end
  end

  describe "insert/2" do
    @insert_listing_params %{
      "type" => "Apartamento",
      "complement" => "100",
      "description" => String.duplicate("a", 256),
      "price" => 1_000_000,
      "floor" => "3",
      "rooms" => 3,
      "bathrooms" => 2,
      "garage_spots" => 1,
      "area" => 100,
      "score" => 3
    }

    test "should insert with description size bigger than 255" do
      address = insert(:address)
      user = insert(:user, role: "user")

      assert {:ok, inserted_listing} = Listings.insert(@insert_listing_params, address.id, user)
      assert retrieved_listing = Repo.get(Listing, inserted_listing.id)
      assert retrieved_listing.address_id == address.id
      assert retrieved_listing.user_id == user.id
    end

    test "should activate for admin user" do
      address = insert(:address)
      user = insert(:user, role: "admin")

      assert {:ok, inserted_listing} = Listings.insert(@insert_listing_params, address.id, user)
      assert retrieved_listing = Repo.get(Listing, inserted_listing.id)
      assert retrieved_listing.is_active
    end

    test "should not activate for normal user" do
      address = insert(:address)
      user = insert(:user, role: "user")

      assert {:ok, inserted_listing} = Listings.insert(@insert_listing_params, address.id, user)
      assert retrieved_listing = Repo.get(Listing, inserted_listing.id)
      refute retrieved_listing.is_active
    end
  end
end
