defmodule Re.FilteringTest do
  use Re.ModelCase

  alias Re.{
    Filtering,
    Listing,
    Listings,
    Listings.Queries,
    Repo
  }

  import Re.Factory

  describe "apply/2: filter by tags_slug" do
    test "filter by tag slug name" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")
      tag_2 = insert(:tag, name: "Tag 2", name_slug: "tag-2")

      {:ok, listing_1} =
        insert(:listing)
        |> Listings.upsert_tags([tag_1.uuid, tag_2.uuid])

      {:ok, _} =
        insert(:listing)
        |> Listings.upsert_tags([tag_2.uuid])

      result =
        Filtering.apply(Listing, %{tags_slug: [tag_1.name_slug]})
        |> Repo.all()

      assert 1 == Enum.count(result)
      assert listing_1.id == Enum.at(result, 0).id
    end

    test "filter by multiple tags slug names" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")
      tag_2 = insert(:tag, name: "Tag 2", name_slug: "tag-2")
      tag_3 = insert(:tag, name: "Tag 3", name_slug: "tag-3")

      {:ok, listing_1} =
        insert(:listing)
        |> Listings.upsert_tags([tag_1.uuid, tag_2.uuid, tag_3.uuid])

      {:ok, listing_2} =
        insert(:listing)
        |> Listings.upsert_tags([tag_2.uuid, tag_3.uuid])

      result =
        Filtering.apply(Listing, %{tags_slug: [tag_2.name_slug, tag_3.name_slug]})
        |> Repo.all()

      assert 2 == Enum.count(result)
      assert Enum.member?(Enum.map(result, & &1.id), listing_1.id)
      assert Enum.member?(Enum.map(result, & &1.id), listing_2.id)
    end

    test "filter by non-existent tag slug name" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")

      {:ok, _} =
        insert(:listing)
        |> Listings.upsert_tags([tag_1.uuid])

      result =
        Filtering.apply(Listing, %{tags_slug: ["non-existent-tag-1"]})
        |> Repo.all()

      assert 0 == Enum.count(result)
    end

    test "filter by empty tag slug name" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")

      {:ok, listing_1} =
        insert(:listing)
        |> Listings.upsert_tags([tag_1.uuid])

      result =
        Filtering.apply(Listing, %{tags_slug: []})
        |> Repo.all()

      assert 1 == Enum.count(result)
      assert Enum.member?(Enum.map(result, & &1.id), listing_1.id)
    end
  end

  describe "apply/2: filter by tags_uuid" do
    test "filter by tag uuid" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")
      tag_2 = insert(:tag, name: "Tag 2", name_slug: "tag-2")

      {:ok, listing_1} =
        insert(:listing)
        |> Listings.upsert_tags([tag_1.uuid, tag_2.uuid])

      {:ok, _} =
        insert(:listing)
        |> Listings.upsert_tags([tag_2.uuid])

      result =
        Filtering.apply(Listing, %{tags_uuid: [tag_1.uuid]})
        |> Repo.all()

      assert 1 == Enum.count(result)
      assert listing_1.id == Enum.at(result, 0).id
    end

    test "filter by multiple tags uuids" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")
      tag_2 = insert(:tag, name: "Tag 2", name_slug: "tag-2")
      tag_3 = insert(:tag, name: "Tag 3", name_slug: "tag-3")

      {:ok, listing_1} =
        insert(:listing)
        |> Listings.upsert_tags([tag_1.uuid, tag_2.uuid, tag_3.uuid])

      {:ok, listing_2} =
        insert(:listing)
        |> Listings.upsert_tags([tag_2.uuid, tag_3.uuid])

      result =
        Filtering.apply(Listing, %{tags_uuid: [tag_2.uuid, tag_3.uuid]})
        |> Repo.all()

      assert 2 == Enum.count(result)
      assert Enum.member?(Enum.map(result, & &1.id), listing_1.id)
      assert Enum.member?(Enum.map(result, & &1.id), listing_2.id)
    end

    test "filter by non-existent tag uuid" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")

      {:ok, _} =
        insert(:listing)
        |> Listings.upsert_tags([tag_1.uuid])

      result =
        Filtering.apply(Listing, %{tags_uuid: [UUID.uuid4()]})
        |> Repo.all()

      assert 0 == Enum.count(result)
    end

    test "filter by empty tag id" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")

      {:ok, listing_1} =
        insert(:listing)
        |> Listings.upsert_tags([tag_1.uuid])

      result =
        Filtering.apply(Listing, %{tags_uuid: []})
        |> Repo.all()

      assert 1 == Enum.count(result)
      assert Enum.member?(Enum.map(result, & &1.id), listing_1.id)
    end
  end

  describe "apply/2" do
    test "filter listing by status return all results with empty arrays" do
      listing = insert(:listing)

      result =
        Listing
        |> Filtering.apply(%{statuses: []})
        |> Repo.all()

      assert [listing] == result
    end

    test "filter listing with one status" do
      listing = insert(:listing, status: "active")
      insert(:listing, status: "inactive")

      result =
        Listing
        |> Filtering.apply(%{statuses: ["active"]})
        |> Repo.all()

      assert [listing] == result
    end

    test "filter listing with multiple statuses" do
      listing_1 = insert(:listing, status: "active")
      listing_2 = insert(:listing, status: "inactive")
      insert(:listing, status: "sold")

      result =
        Listing
        |> Filtering.apply(%{statuses: ["active", "inactive"]})
        |> Repo.all()

      assert [listing_1, listing_2] == result
    end

    test "filter listing with empty orientation fetch all instances" do
      %{id: listing_1} = insert(:listing, orientation: "frente")
      %{id: listing_2} = insert(:listing, orientation: "fundos")
      %{id: listing_3} = insert(:listing, orientation: "lateral")
      %{id: listing_4} = insert(:listing, orientation: "meio")

      result =
        Listing
        |> Filtering.apply(%{orientations: []})
        |> Queries.order_by_id()
        |> Repo.all()
        |> Enum.map(& &1.id)

      assert [listing_1, listing_2, listing_3, listing_4] == result
    end

    test "filter listing by orientation" do
      listing = insert(:listing, orientation: "frente")
      insert(:listing, orientation: "fundos")
      insert(:listing, orientation: "lateral")
      insert(:listing, orientation: "meio")

      result =
        Listing
        |> Filtering.apply(%{orientations: ["frente"]})
        |> Repo.all()

      assert [listing] == result
    end

    test "filter listing with empty sun period fetch all instances" do
      %{id: listing_1} = insert(:listing, sun_period: "morning")
      %{id: listing_2} = insert(:listing, sun_period: "evening")

      result =
        Listing
        |> Filtering.apply(%{sun_periods: []})
        |> Queries.order_by_id()
        |> Repo.all()
        |> Enum.map(& &1.id)

      assert [listing_1, listing_2] == result
    end

    test "filter listing by sun period" do
      listing = insert(:listing, sun_period: "morning")
      insert(:listing, sun_period: "evening")

      result =
        Listing
        |> Filtering.apply(%{sun_periods: ["morning"]})
        |> Repo.all()

      assert [listing] == result
    end

    test "filter listing by floor count" do
      listing_1 = insert(:listing, floor_count: 1)
      listing_2 = insert(:listing, floor_count: 2)
      listing_3 = insert(:listing, floor_count: 3)
      listing_4 = insert(:listing, floor_count: 4)

      result =
        Listing
        |> Filtering.apply(%{min_floor_count: 3})
        |> Repo.all()

      assert [listing_3, listing_4] == result

      result =
        Listing
        |> Filtering.apply(%{max_floor_count: 2})
        |> Repo.all()

      assert [listing_1, listing_2] == result
    end

    test "filter listing by unit per floor" do
      listing_1 = insert(:listing, unit_per_floor: 1)
      listing_2 = insert(:listing, unit_per_floor: 2)
      listing_3 = insert(:listing, unit_per_floor: 3)
      listing_4 = insert(:listing, unit_per_floor: 4)

      result =
        Listing
        |> Filtering.apply(%{min_unit_per_floor: 3})
        |> Repo.all()

      assert [listing_3, listing_4] == result

      result =
        Listing
        |> Filtering.apply(%{max_unit_per_floor: 2})
        |> Repo.all()

      assert [listing_1, listing_2] == result
    end

    test "filter listing by age" do
      base_year = Date.utc_today().year
      listing_1 = insert(:listing, construction_year: base_year - 5)
      listing_2 = insert(:listing, construction_year: base_year - 10)
      listing_3 = insert(:listing, construction_year: base_year - 15)
      listing_4 = insert(:listing, construction_year: base_year - 20)

      result =
        Listing
        |> Filtering.apply(%{max_age: 10})
        |> Repo.all()

      assert [listing_1, listing_2] == result

      result =
        Listing
        |> Filtering.apply(%{min_age: 15})
        |> Repo.all()

      assert [listing_3, listing_4] == result
    end

    test "filter listing by price per area" do
      listing_1 = insert(:listing, price: 10, area: 1, price_per_area: 10)
      listing_2 = insert(:listing, price: 15, area: 1, price_per_area: 15)
      listing_3 = insert(:listing, price: 20, area: 1, price_per_area: 20)
      listing_4 = insert(:listing, price: 25, area: 1, price_per_area: 25)

      result =
        Listing
        |> Filtering.apply(%{min_price_per_area: 20})
        |> Repo.all()

      assert [listing_3, listing_4] == result

      result =
        Listing
        |> Filtering.apply(%{max_price_per_area: 15})
        |> Repo.all()

      assert [listing_1, listing_2] == result
    end
  end
end
