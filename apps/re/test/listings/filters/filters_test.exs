defmodule Re.Listings.FiltersTest do
  use Re.ModelCase

  import Re.{
    CustomAssertion,
    Factory
  }

  alias Re.{
    Listings.Filters,
    Listing,
    Listings,
    Listings.Queries,
    Repo
  }

  describe "apply/2: filter by tags_slug" do
    test "filter by tag slug name" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")
      tag_2 = insert(:tag, name: "Tag 2", name_slug: "tag-2")

      {:ok, %{id: id1}} =
        insert(:listing)
        |> Listings.upsert_tags([tag_1.uuid, tag_2.uuid])

      {:ok, _} =
        insert(:listing)
        |> Listings.upsert_tags([tag_2.uuid])

      result =
        Listing
        |> Filters.apply(%{tags_slug: [tag_1.name_slug]})
        |> Repo.all()

      assert_mapper_match([%{id: id1}], result, &map_id/1)
    end

    test "filter by multiple tags slug names" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")
      tag_2 = insert(:tag, name: "Tag 2", name_slug: "tag-2")
      tag_3 = insert(:tag, name: "Tag 3", name_slug: "tag-3")

      {:ok, %{id: id1}} =
        insert(:listing)
        |> Listings.upsert_tags([tag_1.uuid, tag_2.uuid, tag_3.uuid])

      {:ok, %{id: id2}} =
        insert(:listing)
        |> Listings.upsert_tags([tag_2.uuid, tag_3.uuid])

      result =
        Listing
        |> Filters.apply(%{tags_slug: [tag_2.name_slug, tag_3.name_slug]})
        |> Repo.all()

      assert_mapper_match([%{id: id1}, %{id: id2}], result, &map_id/1)
    end

    test "filter by non-existent tag slug name" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")

      {:ok, _} =
        insert(:listing)
        |> Listings.upsert_tags([tag_1.uuid])

      result =
        Listing
        |> Filters.apply(%{tags_slug: ["non-existent-tag-1"]})
        |> Repo.all()

      assert [] == result
    end

    test "filter by empty tag slug name" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")

      {:ok, %{id: id1}} =
        insert(:listing)
        |> Listings.upsert_tags([tag_1.uuid])

      result =
        Listing
        |> Filters.apply(%{tags_slug: []})
        |> Repo.all()

      assert_mapper_match([%{id: id1}], result, &map_id/1)
    end
  end

  describe "apply/2: filter by tags_uuid" do
    test "filter by tag uuid" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")
      tag_2 = insert(:tag, name: "Tag 2", name_slug: "tag-2")

      {:ok, %{id: id1}} =
        insert(:listing)
        |> Listings.upsert_tags([tag_1.uuid, tag_2.uuid])

      {:ok, _} =
        insert(:listing)
        |> Listings.upsert_tags([tag_2.uuid])

      result =
        Listing
        |> Filters.apply(%{tags_uuid: [tag_1.uuid]})
        |> Repo.all()

      assert_mapper_match([%{id: id1}], result, &map_id/1)
    end

    test "filter by multiple tags uuids" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")
      tag_2 = insert(:tag, name: "Tag 2", name_slug: "tag-2")
      tag_3 = insert(:tag, name: "Tag 3", name_slug: "tag-3")

      {:ok, %{id: id1}} =
        insert(:listing)
        |> Listings.upsert_tags([tag_1.uuid, tag_2.uuid, tag_3.uuid])

      {:ok, %{id: id2}} =
        insert(:listing)
        |> Listings.upsert_tags([tag_2.uuid, tag_3.uuid])

      result =
        Listing
        |> Filters.apply(%{tags_uuid: [tag_2.uuid, tag_3.uuid]})
        |> Repo.all()

      assert_mapper_match([%{id: id1}, %{id: id2}], result, &map_id/1)
    end

    test "filter by non-existent tag uuid" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")

      {:ok, _} =
        insert(:listing)
        |> Listings.upsert_tags([tag_1.uuid])

      result =
        Listing
        |> Filters.apply(%{tags_uuid: [UUID.uuid4()]})
        |> Repo.all()

      assert [] == result
    end

    test "filter by empty tag id" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")

      {:ok, %{id: id1}} =
        insert(:listing)
        |> Listings.upsert_tags([tag_1.uuid])

      result =
        Listing
        |> Filters.apply(%{tags_uuid: []})
        |> Repo.all()

      assert_mapper_match([%{id: id1}], result, &map_id/1)
    end
  end

  describe "apply/2" do
    test "filter listing by status return all results with empty arrays" do
      listing = insert(:listing)

      result =
        Listing
        |> Filters.apply(%{statuses: []})
        |> Repo.all()

      assert [listing] == result
    end

    test "filter listing with one status" do
      listing = insert(:listing, status: "active")
      insert(:listing, status: "inactive")

      result =
        Listing
        |> Filters.apply(%{statuses: ["active"]})
        |> Repo.all()

      assert [listing] == result
    end

    test "filter listing with multiple statuses" do
      %{id: id1} = insert(:listing, status: "active")
      %{id: id2} = insert(:listing, status: "inactive")
      insert(:listing, status: "sold")

      result =
        Listing
        |> Filters.apply(%{statuses: ["active", "inactive"]})
        |> Repo.all()

      assert_mapper_match([%{id: id1}, %{id: id2}], result, &map_id/1)
    end

    test "filter listing with empty orientation fetch all instances" do
      %{id: id1} = insert(:listing, orientation: "frontside")
      %{id: id2} = insert(:listing, orientation: "backside")
      %{id: id3} = insert(:listing, orientation: "lateral")
      %{id: id4} = insert(:listing, orientation: "inside")

      result =
        Listing
        |> Filters.apply(%{orientations: []})
        |> Queries.order_by_id()
        |> Repo.all()

      assert_mapper_match([%{id: id1}, %{id: id2}, %{id: id3}, %{id: id4}], result, &map_id/1)
    end

    test "filter listing by orientation" do
      listing = insert(:listing, orientation: "frontside")
      insert(:listing, orientation: "backside")
      insert(:listing, orientation: "lateral")
      insert(:listing, orientation: "inside")

      result =
        Listing
        |> Filters.apply(%{orientations: ["frontside"]})
        |> Repo.all()

      assert [listing] == result
    end

    test "filter listing with empty sun period fetch all instances" do
      %{id: id1} = insert(:listing, sun_period: "morning")
      %{id: id2} = insert(:listing, sun_period: "evening")

      result =
        Listing
        |> Filters.apply(%{sun_periods: []})
        |> Queries.order_by_id()
        |> Repo.all()

      assert_mapper_match([%{id: id1}, %{id: id2}], result, &map_id/1)
    end

    test "filter listing by sun period" do
      listing = insert(:listing, sun_period: "morning")
      insert(:listing, sun_period: "evening")

      result =
        Listing
        |> Filters.apply(%{sun_periods: ["morning"]})
        |> Repo.all()

      assert [listing] == result
    end

    test "filter listing by floor count" do
      %{id: id1} = insert(:listing, floor_count: 1)
      %{id: id2} = insert(:listing, floor_count: 2)
      %{id: id3} = insert(:listing, floor_count: 3)
      %{id: id4} = insert(:listing, floor_count: 4)

      result =
        Listing
        |> Filters.apply(%{min_floor_count: 3})
        |> Repo.all()

      assert_mapper_match([%{id: id3}, %{id: id4}], result, &map_id/1)

      result =
        Listing
        |> Filters.apply(%{max_floor_count: 2})
        |> Repo.all()

      assert_mapper_match([%{id: id1}, %{id: id2}], result, &map_id/1)
    end

    test "filter listing by unit per floor" do
      %{id: id1} = insert(:listing, unit_per_floor: 1)
      %{id: id2} = insert(:listing, unit_per_floor: 2)
      %{id: id3} = insert(:listing, unit_per_floor: 3)
      %{id: id4} = insert(:listing, unit_per_floor: 4)

      result =
        Listing
        |> Filters.apply(%{min_unit_per_floor: 3})
        |> Repo.all()

      assert_mapper_match([%{id: id3}, %{id: id4}], result, &map_id/1)

      result =
        Listing
        |> Filters.apply(%{max_unit_per_floor: 2})
        |> Repo.all()

      assert_mapper_match([%{id: id1}, %{id: id2}], result, &map_id/1)
    end

    test "filter listing by age" do
      base_year = Date.utc_today().year
      %{id: id1} = insert(:listing, construction_year: base_year - 5)
      %{id: id2} = insert(:listing, construction_year: base_year - 10)
      %{id: id3} = insert(:listing, construction_year: base_year - 15)
      %{id: id4} = insert(:listing, construction_year: base_year - 20)

      result =
        Listing
        |> Filters.apply(%{max_age: 10})
        |> Repo.all()

      assert_mapper_match([%{id: id1}, %{id: id2}], result, &map_id/1)

      result =
        Listing
        |> Filters.apply(%{min_age: 15})
        |> Repo.all()

      assert_mapper_match([%{id: id3}, %{id: id4}], result, &map_id/1)
    end

    test "filter listing by price per area" do
      %{id: id1} = insert(:listing, price: 10, area: 1, price_per_area: 10)
      %{id: id2} = insert(:listing, price: 15, area: 1, price_per_area: 15)
      %{id: id3} = insert(:listing, price: 20, area: 1, price_per_area: 20)
      %{id: id4} = insert(:listing, price: 25, area: 1, price_per_area: 25)

      result =
        Listing
        |> Filters.apply(%{min_price_per_area: 20})
        |> Repo.all()

      assert_mapper_match([%{id: id3}, %{id: id4}], result, &map_id/1)

      result =
        Listing
        |> Filters.apply(%{max_price_per_area: 15})
        |> Repo.all()

      assert_mapper_match([%{id: id1}, %{id: id2}], result, &map_id/1)
    end

    test "filter by max_price" do
      %{id: id} = insert(:listing, price: 1_000_000)
      insert(:listing, price: 2_000_000)

      result =
        Listing
        |> Filters.apply(%{max_price: 1_500_000})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by min_price" do
      %{id: id} = insert(:listing, price: 2_000_000)
      insert(:listing, price: 1_000_000)

      result =
        Listing
        |> Filters.apply(%{min_price: 1_500_000})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by max_rooms" do
      %{id: id} = insert(:listing, rooms: 1)
      insert(:listing, rooms: 5)

      result =
        Listing
        |> Filters.apply(%{max_rooms: 3})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by min_rooms" do
      %{id: id} = insert(:listing, rooms: 5)
      insert(:listing, rooms: 1)

      result =
        Listing
        |> Filters.apply(%{min_rooms: 3})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by max_suites" do
      %{id: id} = insert(:listing, suites: 1)
      insert(:listing, suites: 5)

      result =
        Listing
        |> Filters.apply(%{max_suites: 3})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by min_suites" do
      %{id: id} = insert(:listing, suites: 5)
      insert(:listing, suites: 1)

      result =
        Listing
        |> Filters.apply(%{min_suites: 3})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by max_area" do
      %{id: id} = insert(:listing, area: 50)
      insert(:listing, area: 100)

      result =
        Listing
        |> Filters.apply(%{max_area: 75})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by min_area" do
      %{id: id} = insert(:listing, area: 100)
      insert(:listing, area: 50)

      result =
        Listing
        |> Filters.apply(%{min_area: 75})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by max_garage_spots" do
      %{id: id} = insert(:listing, garage_spots: 5)
      insert(:listing, garage_spots: 10)

      result =
        Listing
        |> Filters.apply(%{max_garage_spots: 7})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by min_garage_spots" do
      %{id: id} = insert(:listing, garage_spots: 10)
      insert(:listing, garage_spots: 5)

      result =
        Listing
        |> Filters.apply(%{min_garage_spots: 7})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by neighborhoods" do
      %{id: id} =
        insert(:listing,
          address: build(:address, neighborhood: "Copacabana")
        )

      insert(:listing,
        address: build(:address, neighborhood: "Perdizes")
      )

      result =
        Listing
        |> Filters.apply(%{neighborhoods: ["Copacabana"]})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by neighborhood_slugs" do
      %{id: id} =
        insert(:listing,
          address: build(:address, neighborhood_slug: "copacabana")
        )

      insert(:listing,
        address: build(:address, neighborhood_slug: "perdizes")
      )

      result =
        Listing
        |> Filters.apply(%{neighborhoods_slugs: ["copacabana"]})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by cities" do
      %{id: id} =
        insert(:listing,
          address: build(:address, city: "Rio de Janeiro")
        )

      insert(:listing,
        address: build(:address, city: "São Paulo")
      )

      result =
        Listing
        |> Filters.apply(%{cities: ["Rio de Janeiro"]})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by cities_slug" do
      %{id: id} =
        insert(:listing,
          address: build(:address, city_slug: "rio-de-janeiro")
        )

      insert(:listing,
        address: build(:address, city_slug: "sao-paulo")
      )

      result =
        Listing
        |> Filters.apply(%{cities_slug: ["rio-de-janeiro"]})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by types" do
      %{id: id} = insert(:listing, type: "Apartamento")

      insert(:listing, type: "Casa")

      result =
        Listing
        |> Filters.apply(%{types: ["Apartamento"]})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by garage_types" do
      %{id: id} = insert(:listing, garage_type: "contract")

      insert(:listing, garage_type: "condominium")

      result =
        Listing
        |> Filters.apply(%{garage_types: ["contract"]})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by max_lat" do
      %{id: id} =
        insert(:listing,
          address: build(:address, lat: 50)
        )

      insert(:listing,
        address: build(:address, lat: 100)
      )

      result =
        Listing
        |> Filters.apply(%{max_lat: 75})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by min_lat" do
      %{id: id} =
        insert(:listing,
          address: build(:address, lat: 100)
        )

      insert(:listing,
        address: build(:address, lat: 50)
      )

      result =
        Listing
        |> Filters.apply(%{min_lat: 75})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by max_lng" do
      %{id: id} =
        insert(:listing,
          address: build(:address, lng: 50)
        )

      insert(:listing,
        address: build(:address, lng: 100)
      )

      result =
        Listing
        |> Filters.apply(%{max_lng: 75})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by min_lng" do
      %{id: id} =
        insert(:listing,
          address: build(:address, lng: 100)
        )

      insert(:listing,
        address: build(:address, lng: 50)
      )

      result =
        Listing
        |> Filters.apply(%{min_lng: 75})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by max_maintenance_fee" do
      %{id: id} = insert(:listing, maintenance_fee: 100.0)
      insert(:listing, maintenance_fee: 120.0)

      result =
        Listing
        |> Filters.apply(%{max_maintenance_fee: 110.0})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by min_maintenance_fee" do
      %{id: id} = insert(:listing, maintenance_fee: 100.0)
      insert(:listing, maintenance_fee: 80.0)

      result =
        Listing
        |> Filters.apply(%{min_maintenance_fee: 90.0})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by max_bathrooms" do
      %{id: id} = insert(:listing, bathrooms: 1)
      insert(:listing, bathrooms: 2)

      result =
        Listing
        |> Filters.apply(%{max_bathrooms: 1})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by min_bathrooms" do
      %{id: id} = insert(:listing, bathrooms: 2)
      insert(:listing, bathrooms: 1)

      result =
        Listing
        |> Filters.apply(%{min_bathrooms: 2})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by is_release when is true" do
      %{id: id} = insert(:listing, is_release: true)
      insert(:listing, is_release: false)

      result =
        Listing
        |> Filters.apply(%{is_release: true})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "filter by is_release when is false" do
      %{id: id} = insert(:listing, is_release: false)
      insert(:listing, is_release: true)

      result =
        Listing
        |> Filters.apply(%{is_release: false})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end

    test "apply all filters at once" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")
      tag_2 = insert(:tag, name: "Tag 2", name_slug: "tag-2")

      _out_of_filters_result =
        insert(
          :listing,
          price: 1_100_000,
          rooms: 3,
          suites: 3,
          area: 90,
          type: "Apartamento",
          address:
            build(
              :address,
              neighborhood: "Copacabana",
              neighborhood_slug: "copacabana",
              lat: 50.0,
              lng: 50.0
            ),
          garage_spots: 2,
          garage_type: "condominium",
          tags: [tag_1],
          price_per_area: 12_222.22,
          maintenance_fee: 120.0
        )

      %{id: id} =
        insert(
          :listing,
          price: 900_000,
          rooms: 3,
          suites: 1,
          bathrooms: 7,
          area: 90,
          type: "Apartamento",
          address:
            build(
              :address,
              neighborhood: "Copacabana",
              neighborhood_slug: "copacabana",
              state: "RJ",
              city: "Rio de Janeiro",
              state_slug: "rj",
              city_slug: "rio-de-janeiro",
              lat: 50.0,
              lng: 50.0
            ),
          garage_spots: 2,
          garage_type: "contract",
          tags: [tag_2],
          price_per_area: 10_000.00,
          maintenance_fee: 100.0
        )

      filters = %{
        max_price: 1_000_000,
        min_price: 800_000,
        max_pricePerArea: 10_500,
        min_pricePerArea: 9_500,
        max_rooms: 4,
        min_rooms: 2,
        max_suites: 2,
        min_suites: 1,
        max_bathrooms: 10,
        min_bathrooms: 5,
        min_area: 80,
        max_area: 100,
        neighborhoods: ["Copacabana", "Leblon"],
        types: ["Apartamento"],
        max_lat: 60.0,
        min_lat: 40.0,
        max_lng: 60.0,
        min_lng: 40.0,
        neighborhoods_slugs: ["copacabana", "leblon"],
        max_garage_spots: 3,
        min_garage_spots: 1,
        garage_types: ["contract"],
        cities: ["Rio de Janeiro"],
        cities_slug: ["rio-de-janeiro"],
        tags_slug: ["tag-2"],
        max_maintenance_fee: 110.0,
        min_maintenance_fee: 90.0
      }

      result =
        Listing
        |> Filters.apply(filters)
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
    end
  end

  defp map_id(items), do: Enum.map(items, & &1.id)
end
