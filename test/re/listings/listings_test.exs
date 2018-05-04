defmodule Re.ListingsTest do
  use Re.ModelCase

  alias Re.{
    Listing,
    Listings
  }

  import Re.Factory

  describe "all/1" do
    test "should return all listings sorted by id" do
      %{id: id1} = insert(:listing, score: 4)
      %{id: id2} = insert(:listing, score: 3)
      %{id: id3} = insert(:listing, score: 4)
      %{id: id4} = insert(:listing, score: 3)

      assert [%{id: ^id1}, %{id: ^id2}, %{id: ^id3}, %{id: ^id4}] = Listings.all()
    end
  end

  describe "paginated/1" do
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

      result = Listings.paginated(%{"max_price" => 105})
      assert [%{id: ^id1}, %{id: ^id3}] = chunk_and_short(result.listings)

      result = Listings.paginated(%{"min_price" => 95})
      assert [%{id: ^id1}, %{id: ^id2}] = chunk_and_short(result.listings)

      result = Listings.paginated(%{"rooms" => 3})
      assert [%{id: ^id2}, %{id: ^id3}] = chunk_and_short(result.listings)

      result = Listings.paginated(%{"max_rooms" => 3})
      assert [%{id: ^id2}, %{id: ^id3}] = chunk_and_short(result.listings)

      result = Listings.paginated(%{"min_rooms" => 4})
      assert [%{id: ^id1}] = chunk_and_short(result.listings)

      result = Listings.paginated(%{"max_area" => 55})
      assert [%{id: ^id1}, %{id: ^id3}] = chunk_and_short(result.listings)

      result = Listings.paginated(%{"neighborhoods" => ["Laranjeiras", "Leblon"]})
      assert [%{id: ^id1}, %{id: ^id2}] = chunk_and_short(result.listings)

      result = Listings.paginated(%{"types" => ["Apartamento"]})
      assert [%{id: ^id1}, %{id: ^id2}] = chunk_and_short(result.listings)

      result = Listings.paginated(%{"max_lat" => -22.95})
      assert [%{id: ^id1}, %{id: ^id3}] = chunk_and_short(result.listings)

      result = Listings.paginated(%{"min_lat" => -22.98})
      assert [%{id: ^id1}, %{id: ^id2}] = chunk_and_short(result.listings)

      result = Listings.paginated(%{"max_lng" => -43.199})
      assert [%{id: ^id1}, %{id: ^id2}] = chunk_and_short(result.listings)

      result = Listings.paginated(%{"min_lng" => -43.203})
      assert [%{id: ^id1}, %{id: ^id3}] = chunk_and_short(result.listings)
    end

    test "should not filter for empty array" do
      laranjeiras = insert(:address, street: "astreet", neighborhood: "Laranjeiras")
      leblon = insert(:address, street: "anotherstreet", neighborhood: "Leblon")
      botafogo = insert(:address, street: "onemorestreet", neighborhood: "Botafogo")

      %{id: id1} = insert(:listing, score: 4, address_id: laranjeiras.id, type: "Apartamento")
      %{id: id2} = insert(:listing, score: 3, address_id: leblon.id, type: "Casa")
      %{id: id3} = insert(:listing, score: 2, address_id: botafogo.id, type: "Apartamento")

      result = Listings.paginated(%{"neighborhoods" => []})
      assert [%{id: ^id1}, %{id: ^id2}, %{id: ^id3}] = chunk_and_short(result.listings)

      result = Listings.paginated(%{"types" => []})
      assert [%{id: ^id1}, %{id: ^id2}, %{id: ^id3}] = chunk_and_short(result.listings)
    end

    test "should return paginated result" do
      insert(:listing, score: 4)
      insert(:listing, score: 4)
      %{id: id3} = insert(:listing, score: 3)

      assert %{remaining_count: 1, listings: [%{id: id1}, %{id: id2}]} =
               Listings.paginated(%{page_size: 2})

      assert %{remaining_count: 0, listings: [%{id: ^id3}]} =
               Listings.paginated(%{page_size: 2, excluded_listing_ids: [id1, id2]})
    end

    test "should paginate excluding listings already returned" do
      insert_list(12, :listing)

      assert %{remaining_count: 8, listings: listings1} = Listings.paginated(%{page_size: 4})
      assert 4 == length(listings1)
      listing_ids1 = Enum.map(listings1, &Map.get(&1, :id))

      assert %{remaining_count: 4, listings: listings2} =
               Listings.paginated(%{page_size: 4, excluded_listing_ids: listing_ids1})

      assert 4 == length(listings2)
      listing_ids2 = Enum.map(listings2, &Map.get(&1, :id))

      assert %{remaining_count: 0, listings: listings3} =
               Listings.paginated(%{
                 page_size: 4,
                 excluded_listing_ids: listing_ids1 ++ listing_ids2
               })

      assert 4 == length(listings3)
      listing_ids3 = Enum.map(listings3, &Map.get(&1, :id))

      result_ids = listing_ids1 ++ listing_ids2 ++ listing_ids3
      assert result_ids == Enum.uniq(result_ids)
    end
  end

  describe "deactivate/1" do
    test "should set is_active to false" do
      listing = insert(:listing)

      {:ok, listing} = Listings.deactivate(listing)
      refute listing.is_active
    end
  end

  describe "activate/1" do
    test "should set is_active to true" do
      listing = insert(:listing, is_active: false)

      {:ok, listing} = Listings.activate(listing)
      assert listing.is_active
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

      assert {:ok, inserted_listing} = Listings.insert(@insert_listing_params, address, user)
      assert retrieved_listing = Repo.get(Listing, inserted_listing.id)
      assert retrieved_listing.address_id == address.id
      assert retrieved_listing.user_id == user.id
    end

    test "should insert inactive for admin user" do
      address = insert(:address)
      user = insert(:user, role: "admin")

      assert {:ok, inserted_listing} = Listings.insert(@insert_listing_params, address, user)
      assert retrieved_listing = Repo.get(Listing, inserted_listing.id)
      refute retrieved_listing.is_active
    end

    test "should insert inactive for normal user" do
      address = insert(:address)
      user = insert(:user, role: "user")

      assert {:ok, inserted_listing} = Listings.insert(@insert_listing_params, address, user)
      assert retrieved_listing = Repo.get(Listing, inserted_listing.id)
      refute retrieved_listing.is_active
    end
  end

  defp chunk_and_short(listings) do
    listings
    |> Enum.chunk_by(& &1.score)
    |> Enum.map(&Enum.sort/1)
    |> List.flatten()
  end
end
