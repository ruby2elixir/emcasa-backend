defmodule Re.ListingsTest do
  use Re.ModelCase

  import Re.CustomAssertion

  alias Re.{
    Listings.History.Server,
    Listing,
    Listings,
    Listings.JobQueue,
    Repo
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
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")
      tag_2 = insert(:tag, name: "Tag 2", name_slug: "tag-2")
      tag_3 = insert(:tag, name: "Tag 3", name_slug: "tag-3")

      sao_conrado =
        insert(
          :address,
          street: "astreet",
          neighborhood: "São Conrado",
          neighborhood_slug: "sao-conrado",
          lat: -22.9675614,
          lng: -43.20261119999998
        )

      leblon =
        insert(
          :address,
          street: "anotherstreet",
          neighborhood: "Leblon",
          neighborhood_slug: "leblon",
          lat: -22.9461014,
          lng: -43.21675540000001
        )

      botafogo =
        insert(
          :address,
          street: "onemorestreet",
          neighborhood: "Botafogo",
          neighborhood_slug: "botafogo",
          state: "SP",
          city: "São Paulo",
          state_slug: "sp",
          city_slug: "sao-paulo",
          lat: -22.9961014,
          lng: -43.19675540000001
        )

      %{id: id1} =
        insert(
          :listing,
          price: 100,
          area: 40,
          rooms: 4,
          suites: 1,
          score: 4,
          address_id: sao_conrado.id,
          type: "Apartamento",
          garage_spots: 3,
          garage_type: "contract",
          tags: [tag_1, tag_2]
        )

      %{id: id2} =
        insert(
          :listing,
          price: 110,
          area: 60,
          rooms: 3,
          suites: 2,
          score: 3,
          address_id: leblon.id,
          type: "Apartamento",
          garage_spots: 2,
          garage_type: "condominium",
          tags: [tag_1, tag_2, tag_3]
        )

      %{id: id3} =
        insert(
          :listing,
          price: 90,
          area: 50,
          rooms: 3,
          suites: 3,
          score: 2,
          address_id: botafogo.id,
          type: "Casa",
          garage_spots: 1,
          garage_type: "contract",
          tags: [tag_3]
        )

      result = Listings.paginated(%{"max_price" => 105})
      assert_mapper_match([%{id: id1}, %{id: id3}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"min_price" => 95})
      assert_mapper_match([%{id: id1}, %{id: id2}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"max_rooms" => 3})
      assert_mapper_match([%{id: id2}, %{id: id3}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"min_rooms" => 4})
      assert_mapper_match([%{id: id1}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"max_suites" => 2})
      assert_mapper_match([%{id: id1}, %{id: id2}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"min_suites" => 2})
      assert_mapper_match([%{id: id2}, %{id: id3}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"max_area" => 55})
      assert_mapper_match([%{id: id1}, %{id: id3}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"neighborhoods" => ["São Conrado", "Leblon"]})
      assert_mapper_match([%{id: id1}, %{id: id2}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"neighborhoods_slugs" => ["sao-conrado", "leblon"]})
      assert_mapper_match([%{id: id1}, %{id: id2}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"types" => ["Apartamento"]})
      assert_mapper_match([%{id: id1}, %{id: id2}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"max_lat" => -22.95})
      assert_mapper_match([%{id: id1}, %{id: id3}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"min_lat" => -22.98})
      assert_mapper_match([%{id: id1}, %{id: id2}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"max_lng" => -43.199})
      assert_mapper_match([%{id: id1}, %{id: id2}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"min_lng" => -43.203})
      assert_mapper_match([%{id: id1}, %{id: id3}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"max_garage_spots" => 2})
      assert_mapper_match([%{id: id2}, %{id: id3}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"min_garage_spots" => 2})
      assert_mapper_match([%{id: id1}, %{id: id2}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"garage_types" => ["contract", "condominium"]})
      assert_mapper_match([%{id: id1}, %{id: id2}, %{id: id3}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"garage_types" => ["contract"]})
      assert_mapper_match([%{id: id1}, %{id: id3}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"garage_types" => ["condominium"]})
      assert_mapper_match([%{id: id2}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"cities" => ["São Paulo"]})
      assert_mapper_match([%{id: id3}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"cities_slug" => ["sao-paulo"]})
      assert_mapper_match([%{id: id3}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"tags_slug" => ["tag-2"]})
      assert_mapper_match([%{id: id1}, %{id: id2}], result.listings, &map_id/1)
      assert 0 == result.remaining_count

      result = Listings.paginated(%{"tags_slug" => ["tag-1", "tag-2"], "page_size" => 1})
      assert_mapper_match([%{id: id1}], result.listings, &map_id/1)
      assert 1 == result.remaining_count
    end

    test "should not filter for empty array" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")
      tag_2 = insert(:tag, name: "Tag 2", name_slug: "tag-2")
      tag_3 = insert(:tag, name: "Tag 3", name_slug: "tag-3")

      laranjeiras = insert(:address, street: "astreet", neighborhood: "Laranjeiras")
      leblon = insert(:address, street: "anotherstreet", neighborhood: "Leblon")
      botafogo = insert(:address, street: "onemorestreet", neighborhood: "Botafogo")

      %{id: id1} =
        insert(:listing, score: 4, address_id: laranjeiras.id, type: "Apartamento", tags: [tag_1])

      %{id: id2} = insert(:listing, score: 3, address_id: leblon.id, type: "Casa", tags: [tag_2])

      %{id: id3} =
        insert(:listing, score: 2, address_id: botafogo.id, type: "Apartamento", tags: [tag_3])

      result = Listings.paginated(%{"neighborhoods" => []})
      assert_mapper_match([%{id: id1}, %{id: id2}, %{id: id3}], result.listings, &map_id/1)

      result = Listings.paginated(%{"types" => []})
      assert_mapper_match([%{id: id1}, %{id: id2}, %{id: id3}], result.listings, &map_id/1)

      result = Listings.paginated(%{"garage_types" => []})
      assert_mapper_match([%{id: id1}, %{id: id2}, %{id: id3}], result.listings, &map_id/1)

      result = Listings.paginated(%{"tags_slug" => []})
      assert_mapper_match([%{id: id1}, %{id: id2}, %{id: id3}], result.listings, &map_id/1)

      result = Listings.paginated(%{"tags_uuid" => []})
      assert_mapper_match([%{id: id1}, %{id: id2}, %{id: id3}], result.listings, &map_id/1)
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

    test "should return paginated with filter" do
      insert(:listing, score: 4, garage_spots: 5)
      %{id: id} = insert(:listing, score: 3, garage_spots: 3)
      insert(:listing, score: 2, garage_spots: 3)

      assert %{remaining_count: 1, listings: [%{id: ^id}]} =
               Listings.paginated(%{page_size: 1, max_garage_spots: 4})
    end

    test "should order by attributes" do
      %{id: id1} = insert(:listing, garage_spots: 1, price: 1_000_000, rooms: 2)
      %{id: id2} = insert(:listing, garage_spots: 2, price: 900_000, rooms: 3, score: 4)
      %{id: id3} = insert(:listing, garage_spots: 3, price: 1_100_000, rooms: 4)
      %{id: id4} = insert(:listing, garage_spots: 2, price: 1_000_000, rooms: 3)
      %{id: id5} = insert(:listing, garage_spots: 2, price: 900_000, rooms: 3, score: 3)
      %{id: id6} = insert(:listing, garage_spots: 3, price: 1_100_000, rooms: 5)

      assert %{
               listings: [
                 %{id: ^id3},
                 %{id: ^id6},
                 %{id: ^id4},
                 %{id: ^id1},
                 %{id: ^id2},
                 %{id: ^id5}
               ]
             } =
               Listings.paginated(%{
                 order_by: [
                   %{field: :price, type: :desc},
                   %{field: :garage_spots, type: :desc},
                   %{field: :rooms, type: :asc}
                 ]
               })
    end

    test "should order by inserted_at asc" do
      %{id: id1} = insert(:listing, inserted_at: ~N[2010-01-01 10:00:00])
      %{id: id2} = insert(:listing, inserted_at: ~N[2010-01-02 10:00:00])
      %{id: id3} = insert(:listing, inserted_at: ~N[2010-01-03 10:00:00])

      assert %{
               listings: [
                 %{id: ^id1},
                 %{id: ^id2},
                 %{id: ^id3}
               ]
             } = Listings.paginated(%{order_by: [%{field: :inserted_at, type: :asc}]})
    end

    test "should order by inserted_at desc" do
      %{id: id1} = insert(:listing, inserted_at: ~N[2010-01-01 10:00:00])
      %{id: id2} = insert(:listing, inserted_at: ~N[2010-01-02 10:00:00])
      %{id: id3} = insert(:listing, inserted_at: ~N[2010-01-03 10:00:00])

      assert %{
               listings: [
                 %{id: ^id3},
                 %{id: ^id2},
                 %{id: ^id1}
               ]
             } = Listings.paginated(%{order_by: [%{field: :inserted_at, type: :desc}]})
    end

    test "should order by floor asc" do
      %{id: id1} = insert(:listing, floor: "1")
      %{id: id2} = insert(:listing, floor: "2")
      %{id: id3} = insert(:listing, floor: "A")

      assert %{
               listings: [
                 %{id: ^id1},
                 %{id: ^id2},
                 %{id: ^id3}
               ]
             } = Listings.paginated(%{order_by: [%{field: :floor, type: :asc}]})
    end

    test "should order by floor desc" do
      %{id: id1} = insert(:listing, floor: "1")
      %{id: id2} = insert(:listing, floor: "2")
      %{id: id3} = insert(:listing, floor: "A")

      assert %{
               listings: [
                 %{id: ^id3},
                 %{id: ^id2},
                 %{id: ^id1}
               ]
             } = Listings.paginated(%{order_by: [%{field: :floor, type: :desc}]})
    end
  end

  describe "deactivate/2" do
    test "should set status to inactive with reason" do
      listing = insert(:listing, status: "active")

      {:ok, listing} = Listings.deactivate(listing, reason: "rented")

      assert listing.status == "inactive"
      assert listing.inactivation_reason == "rented"
    end

    test "should save status change to history when set to inactive" do
      Server.start_link()
      listing = insert(:listing, status: "active")

      {:ok, _listing} = Listings.deactivate(listing)

      GenServer.call(Server, :inspect)

      status_history = Repo.one(Re.Listings.StatusHistory)
      assert "active" == status_history.status
    end
  end

  describe "activate/1" do
    test "should set status to active and clean inativation_reason" do
      listing = insert(:listing, status: "inactive", inactivation_reason: "rented")

      {:ok, listing} = Listings.activate(listing)

      assert listing.status == "active"
      assert listing.inactivation_reason == nil
    end

    test "should save old status on history" do
      Server.start_link()
      listing = insert(:listing, status: "inactive")

      {:ok, _listing} = Listings.activate(listing)

      GenServer.call(Server, :inspect)

      status_history = Repo.one(Re.Listings.StatusHistory)
      assert "inactive" == status_history.status
    end

    test "should enqueue save_price_suggestion" do
      listing = insert(:listing, status: "inactive")

      {:ok, _listing} = Listings.activate(listing)

      assert_enqueued_job(Repo.all(JobQueue), "save_price_suggestion")
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
      "area" => 100
    }

    @insert_admin_listing_params %{
      "type" => "Apartamento",
      "complement" => "100",
      "description" => String.duplicate("a", 256),
      "price" => 1_000_000,
      "floor" => "3",
      "rooms" => 3,
      "bathrooms" => 2,
      "garage_spots" => 1,
      "area" => 100,
      "score" => 3,
      "orientation" => "frontside",
      "sun_period" => "morning",
      "floor_count" => 10,
      "unit_per_floor" => 4,
      "elevators" => 2,
      "construction_year" => 2005
    }

    test "should insert listing with defaults when has no values" do
      address = insert(:address)
      user = insert(:user, role: "user")
      owner_contact = insert(:owner_contact)

      assert {:ok, inserted_listing} =
               Listings.insert(@insert_listing_params,
                 address: address,
                 user: user,
                 owner_contact: owner_contact
               )

      assert retrieved_listing = Repo.get(Listing, inserted_listing.id)
      assert retrieved_listing.uuid
      assert retrieved_listing.is_release == false
      assert retrieved_listing.is_exportable == true
    end

    test "should insert with description size bigger than 255" do
      address = insert(:address)
      user = insert(:user, role: "user")
      owner_contact = insert(:owner_contact)

      assert {:ok, inserted_listing} =
               Listings.insert(@insert_listing_params,
                 address: address,
                 user: user,
                 owner_contact: owner_contact
               )

      assert retrieved_listing = Repo.get(Listing, inserted_listing.id)
      assert retrieved_listing.address_id == address.id
      assert retrieved_listing.user_id == user.id
      assert retrieved_listing.owner_contact_uuid == owner_contact.uuid
      assert retrieved_listing.uuid
    end

    test "should insert inactive for admin user" do
      address = insert(:address)
      user = insert(:user, role: "admin")
      owner_contact = insert(:owner_contact)

      assert {:ok, inserted_listing} =
               Listings.insert(@insert_admin_listing_params,
                 address: address,
                 user: user,
                 owner_contact: owner_contact
               )

      assert retrieved_listing = Repo.get(Listing, inserted_listing.id)
      assert retrieved_listing.status == "inactive"

      assert retrieved_listing.price_per_area ==
               @insert_admin_listing_params["price"] / @insert_admin_listing_params["area"]
    end

    test "should insert inactive for normal user" do
      address = insert(:address)
      user = insert(:user, role: "user")

      assert {:ok, inserted_listing} =
               Listings.insert(@insert_listing_params, address: address, user: user)

      assert retrieved_listing = Repo.get(Listing, inserted_listing.id)
      assert retrieved_listing.status == "inactive"

      assert retrieved_listing.price_per_area ==
               @insert_listing_params["price"] / @insert_listing_params["area"]
    end

    test "should insert if owner contact is nil" do
      address = insert(:address)
      user = insert(:user, role: "admin")

      assert {:ok, inserted_listing} =
               Listings.insert(@insert_admin_listing_params,
                 address: address,
                 user: user,
                 owner_contact: nil
               )
    end
  end

  describe "update/4" do
    test "should not save price history if price is not changed" do
      user = insert(:user)
      address = insert(:address)
      listing = insert(:listing, user: user, rooms: 3)

      Listings.update(listing, %{rooms: 4}, address: address, user: user)

      refute Repo.one(Re.Listings.PriceHistory)
      assert_enqueued_job(Repo.all(JobQueue), "save_price_suggestion")
    end

    test "should update owner contact" do
      user = insert(:user)
      address = insert(:address)
      original_owner_contact = insert(:owner_contact)
      listing = insert(:listing, user: user, owner_contact: original_owner_contact)

      updated_owner_contact = insert(:owner_contact)

      Listings.update(listing, %{},
        address: address,
        user: user,
        owner_contact: updated_owner_contact
      )

      updated_listing = Repo.get(Listing, listing.id)
      assert updated_listing.owner_contact_uuid == updated_owner_contact.uuid
      assert_enqueued_job(Repo.all(JobQueue), "save_price_suggestion")
    end

    test "should update if owner contact is nil" do
      user = insert(:user)
      address = insert(:address)
      original_owner_contact = insert(:owner_contact)
      listing = insert(:listing, user: user, owner_contact: original_owner_contact)

      Listings.update(listing, %{},
        address: address,
        user: user,
        owner_contact: nil
      )

      updated_listing = Repo.get(Listing, listing.id)
      assert updated_listing.owner_contact_uuid == original_owner_contact.uuid
      assert_enqueued_job(Repo.all(JobQueue), "save_price_suggestion")
    end

    test "should not change user who created listing" do
      original_user = insert(:user)
      address = insert(:address)
      listing = insert(:listing, address: address, user: original_user, rooms: 3)

      updated_user = insert(:user)
      assert updated_user.id != original_user.id

      Listings.update(listing, %{rooms: 4}, address: address, user: updated_user)

      updated_listing = Repo.get(Listing, listing.id)
      assert updated_listing.user_id == original_user.id
      assert_enqueued_job(Repo.all(JobQueue), "save_price_suggestion")
    end
  end

  describe "upsert_tags/2" do
    test "should insert tags" do
      tag_1 = insert(:tag, name: "tag 1", name_slug: "tag-1")
      tag_2 = insert(:tag, name: "tag 2", name_slug: "tag-2")
      tag_3 = insert(:tag, name: "tag 3", name_slug: "tag-3")

      user = insert(:user)

      listing =
        insert(:listing, user: user)
        |> Repo.preload([:tags])

      assert [] == listing.tags

      assert {:ok, updated_listing} = Listings.upsert_tags(listing, [tag_1.uuid, tag_2.uuid])

      assert Enum.count(updated_listing.tags) == 2
      assert Enum.member?(updated_listing.tags, tag_1)
      assert Enum.member?(updated_listing.tags, tag_2)
      refute Enum.member?(updated_listing.tags, tag_3)
    end

    test "should update tags" do
      tag_1 = insert(:tag, name: "tag 1", name_slug: "tag-1")
      tag_2 = insert(:tag, name: "tag 2", name_slug: "tag-2")
      tag_3 = insert(:tag, name: "tag 3", name_slug: "tag-3")

      user = insert(:user)

      listing = insert(:listing, user: user, tags: [tag_1, tag_2])

      {:ok, updated_listing} = Listings.upsert_tags(listing, [tag_3.uuid])

      assert Enum.count(updated_listing.tags) == 1
      assert Enum.member?(updated_listing.tags, tag_3)
      refute Enum.member?(updated_listing.tags, tag_1)
      refute Enum.member?(updated_listing.tags, tag_2)
    end

    test "should remove tags" do
      tag_1 = insert(:tag, name: "tag 1", name_slug: "tag-1")
      tag_2 = insert(:tag, name: "tag 2", name_slug: "tag-2")

      user = insert(:user)

      listing = insert(:listing, user: user, tags: [tag_1, tag_2])

      {:ok, updated_listing} = Listings.upsert_tags(listing, [])

      assert [] == updated_listing.tags
      refute Enum.member?(updated_listing.tags, tag_1)
      refute Enum.member?(updated_listing.tags, tag_2)
    end

    test "should not upsert when tags is nil" do
      tag_1 = insert(:tag, name: "tag 1", name_slug: "tag-1")
      tag_2 = insert(:tag, name: "tag 2", name_slug: "tag-2")

      user = insert(:user)

      listing = insert(:listing, user: user, tags: [tag_1, tag_2])

      {:ok, updated_listing} = Listings.upsert_tags(listing, nil)

      assert Enum.count(updated_listing.tags) == 2
      assert Enum.member?(updated_listing.tags, tag_1)
      assert Enum.member?(updated_listing.tags, tag_2)
    end
  end

  defp map_id(items), do: Enum.map(items, & &1.id)
end
