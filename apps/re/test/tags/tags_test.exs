defmodule Re.TagsTest do
  use Re.ModelCase

  alias Re.{
    Tag,
    Tags
  }

  import Re.Factory

  describe "with_ids/1" do
    test "should fetch tags with uuids" do
      %{uuid: uuid_1} = insert(:tag, name: "feature 1", name_slug: "feature-1")
      %{uuid: uuid_2} = insert(:tag, name: "feature 2", name_slug: "feature-2")
      %{uuid: uuid_3} = insert(:tag, name: "feature 3", name_slug: "feature-3")

      tags_uuids =
        Tags.list_by_ids([uuid_1, uuid_2])
        |> Enum.map(fn tag -> tag.uuid end)

      assert Enum.member?(tags_uuids, uuid_1)
      assert Enum.member?(tags_uuids, uuid_2)
      refute Enum.member?(tags_uuids, uuid_3)
    end
  end

  describe "with_slugs/1" do
    test "should fetch tags with slugs" do
      %{name_slug: slug_1} = insert(:tag, name: "feature 1", name_slug: "feature-1")
      %{name_slug: slug_2} = insert(:tag, name: "feature 2", name_slug: "feature-2")
      %{name_slug: slug_3} = insert(:tag, name: "feature 3", name_slug: "feature-3")

      tags_slugs =
        Tags.list_by_slugs([slug_1, slug_2])
        |> Enum.map(fn tag -> tag.name_slug end)

      assert Enum.member?(tags_slugs, slug_1)
      assert Enum.member?(tags_slugs, slug_2)
      refute Enum.member?(tags_slugs, slug_3)
    end
  end

  describe "insert/1" do
    test "should insert a tag" do
      attrs = %{name: "an awesome feature", category: "realty"}
      assert {:ok, inserted_tag} = Tags.insert(attrs)

      assert fetched_tag = Repo.get(Tag, inserted_tag.uuid)
      assert fetched_tag.name_slug == inserted_tag.name_slug
    end

    test "should fail when inserting tag with same name_slug" do
      original_attrs = %{name: "Varanda gourmet", category: "realty"}
      assert {:ok, _} = Tags.insert(original_attrs)

      duplicate_attrs = %{name: "Varanda Gourmet", category: "infrastructure"}
      assert {:error, changeset} = Tags.insert(duplicate_attrs)

      assert Keyword.get(changeset.errors, :name_slug) ==
               {"has already been taken",
                [constraint: :unique, constraint_name: "tags_name_slug_index"]}
    end
  end

  describe "update/2" do
    test "should update tag with new attributes" do
      tag = insert(:tag)

      new_attrs = params_for(:tag)

      Tags.update(tag, new_attrs)

      updated_tag = Repo.get(Tag, tag.uuid)

      assert updated_tag.name == Map.get(new_attrs, :name)
      assert updated_tag.name_slug == Map.get(new_attrs, :name_slug)
      assert updated_tag.category == Map.get(new_attrs, :category)
    end
  end
end
