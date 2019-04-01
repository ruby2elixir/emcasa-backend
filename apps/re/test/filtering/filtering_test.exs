defmodule Re.FilteringTest do
  use Re.ModelCase

  alias Re.{
    Filtering,
    Listing,
    Listings,
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
end
