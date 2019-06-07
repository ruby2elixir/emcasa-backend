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
      assert 1 == Enum.count(result)
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
      assert 2 == Enum.count(result)
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
      assert 1 == Enum.count(result)
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
      assert 1 == Enum.count(result)
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
      assert 2 == Enum.count(result)
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
      assert 1 == Enum.count(result)
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
      assert 2 == Enum.count(result)
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
      assert 4 == Enum.count(result)
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
      assert 2 == Enum.count(result)
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
      assert 2 == Enum.count(result)

      result =
        Listing
        |> Filters.apply(%{max_floor_count: 2})
        |> Repo.all()

      assert_mapper_match([%{id: id1}, %{id: id2}], result, &map_id/1)
      assert 2 == Enum.count(result)
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
      assert 2 == Enum.count(result)

      result =
        Listing
        |> Filters.apply(%{max_unit_per_floor: 2})
        |> Repo.all()

      assert_mapper_match([%{id: id1}, %{id: id2}], result, &map_id/1)
      assert 2 == Enum.count(result)
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
      assert 2 == Enum.count(result)

      result =
        Listing
        |> Filters.apply(%{min_age: 15})
        |> Repo.all()

      assert_mapper_match([%{id: id3}, %{id: id4}], result, &map_id/1)
      assert 2 == Enum.count(result)
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
      assert 2 == Enum.count(result)
    end
  end

  describe "apply/2: filter by maintenance_fee" do
    test "filter by max" do
      %{id: id} = insert(:listing, maintenance_fee: 100.0)
      insert(:listing, maintenance_fee: 120.0)

      result =
        Listing
        |> Filters.apply(%{max_maintenance_fee: 110.0})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
      assert 1 == Enum.count(result)
    end

    test "filter by min" do
      %{id: id} = insert(:listing, maintenance_fee: 100.0)
      insert(:listing, maintenance_fee: 80.0)

      result =
        Listing
        |> Filters.apply(%{min_maintenance_fee: 90.0})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
      assert 1 == Enum.count(result)
    end

    test "filter by max and min" do
      insert(:listing, maintenance_fee: 120.0)
      %{id: id} = insert(:listing, maintenance_fee: 100.0)
      insert(:listing, maintenance_fee: 80.0)

      result =
        Listing
        |> Filters.apply(%{min_maintenance_fee: 90.0, max_maintenance_fee: 110.0})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
      assert 1 == Enum.count(result)
    end
  end

  describe "apply/2: filter by bathrooms" do
    test "filter by max" do
      %{id: id} = insert(:listing, bathrooms: 1)
      insert(:listing, bathrooms: 2)

      result =
        Listing
        |> Filters.apply(%{max_bathrooms: 1})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
      assert 1 == Enum.count(result)
    end

    test "filter by min" do
      %{id: id} = insert(:listing, bathrooms: 2)
      insert(:listing, bathrooms: 1)

      result =
        Listing
        |> Filters.apply(%{min_bathrooms: 2})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
      assert 1 == Enum.count(result)
    end

    test "filter by max and min" do
      insert(:listing, bathrooms: 1)
      %{id: id} = insert(:listing, bathrooms: 3)
      insert(:listing, bathrooms: 5)

      result =
        Listing
        |> Filters.apply(%{min_bathrooms: 2, max_bathrooms: 4})
        |> Repo.all()

      assert_mapper_match([%{id: id}], result, &map_id/1)
      assert 1 == Enum.count(result)
    end
  end

  defp map_id(items), do: Enum.map(items, & &1.id)
end
