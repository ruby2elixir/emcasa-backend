defmodule Re.TagsTest do
  use Re.ModelCase

  alias Re.{
    Tag,
    Tags,
    User
  }

  import Re.Factory

  describe "all/1" do
    test "should fetch all tags for user with admin role" do
      %{uuid: uuid_1} = insert(:tag, name: "feature 1", name_slug: "feature-1")
      %{uuid: uuid_2} = insert(:tag, name: "feature 2", name_slug: "feature-2")
      %{uuid: uuid_3} = insert(:tag, name: "feature 3", name_slug: "feature-3")

      tags_uuids =
        Tags.all(%User{role: "admin"})
        |> Enum.map(fn tag -> tag.uuid end)

      assert Enum.member?(tags_uuids, uuid_1)
      assert Enum.member?(tags_uuids, uuid_2)
      assert Enum.member?(tags_uuids, uuid_3)
    end

    test "should fetch only public visible tags for user with user role" do
      %{uuid: uuid_1} =
        insert(:tag, name: "feature 1", name_slug: "feature-1", visibility: "public")

      %{uuid: uuid_2} =
        insert(:tag, name: "feature 2", name_slug: "feature-2", visibility: "public")

      %{uuid: uuid_3} =
        insert(:tag, name: "feature 3", name_slug: "feature-3", visibility: "private")

      tags_uuids =
        Tags.all(%User{role: "user"})
        |> Enum.map(fn tag -> tag.uuid end)

      assert Enum.member?(tags_uuids, uuid_1)
      assert Enum.member?(tags_uuids, uuid_2)
      refute Enum.member?(tags_uuids, uuid_3)
    end
  end

  describe "search/1" do
    test "should fetch matching tags" do
      %{uuid: uuid_1} = insert(:tag, name: "Open space", name_slug: "open-space")
      %{uuid: uuid_2} = insert(:tag, name: "Leisure Area", name_slug: "leisure-area")
      %{uuid: uuid_3} = insert(:tag, name: "Barbecue Area", name_slug: "barbecue-area")

      tags_uuids =
        Tags.search("area")
        |> Enum.map(& &1.uuid)

      refute Enum.member?(tags_uuids, uuid_1)
      assert Enum.member?(tags_uuids, uuid_2)
      assert Enum.member?(tags_uuids, uuid_3)
    end
  end

  describe "get/2" do
    test "should fetch public visible tag for user with admin role" do
      %{uuid: uuid_1} =
        insert(:tag, name: "feature 1", name_slug: "feature-1", visibility: "public")

      insert(:tag, name: "feature 2", name_slug: "feature-2")
      insert(:tag, name: "feature 3", name_slug: "feature-3")

      {:ok, tag} = Tags.get(uuid_1, %User{role: "admin"})

      assert uuid_1 == tag.uuid
    end

    test "should fetch private visible tag for user with admin role" do
      %{uuid: uuid_1} =
        insert(:tag, name: "feature 1", name_slug: "feature-1", visibility: "private")

      insert(:tag, name: "feature 2", name_slug: "feature-2")
      insert(:tag, name: "feature 3", name_slug: "feature-3")

      {:ok, tag} = Tags.get(uuid_1, %User{role: "admin"})

      assert uuid_1 == tag.uuid
    end

    test "should fetch public visible tag for user with user role" do
      %{uuid: uuid_1} =
        insert(:tag, name: "feature 1", name_slug: "feature-1", visibility: "public")

      {:ok, tag} = Tags.get(uuid_1, %User{role: "user"})

      assert uuid_1 == tag.uuid
    end

    test "should return error when fetching tag with private visibility for user with user role" do
      %{uuid: uuid_1} =
        insert(:tag, name: "feature 2", name_slug: "feature-2", visibility: "private")

      assert {:error, :not_found} = Tags.get(uuid_1, %User{role: "user"})
    end

    test "should fetch public visible tag for no user" do
      %{uuid: uuid_1} =
        insert(:tag, name: "feature 1", name_slug: "feature-1", visibility: "public")

      {:ok, tag} = Tags.get(uuid_1, nil)

      assert uuid_1 == tag.uuid
    end

    test "should return error when fetching tag with private visibility for no user" do
      %{uuid: uuid_1} =
        insert(:tag, name: "feature 2", name_slug: "feature-2", visibility: "private")

      assert {:error, :not_found} = Tags.get(uuid_1, nil)
    end

    test "should return error when no tag is found" do
      insert(:tag, name: "feature 1", name_slug: "feature-1")

      assert {:error, :not_found} = Tags.get(UUID.uuid4(), %User{role: "user"})
    end
  end

  describe "with_ids/1" do
    test "should fetch tags with uuids" do
      %{uuid: uuid_1} = insert(:tag, name: "feature 1", name_slug: "feature-1")
      %{uuid: uuid_2} = insert(:tag, name: "feature 2", name_slug: "feature-2")
      %{uuid: uuid_3} = insert(:tag, name: "feature 3", name_slug: "feature-3")

      tags_uuids =
        Tags.list_by_uuids([uuid_1, uuid_2])
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
      attrs = %{name: "an awesome feature", category: "realty", visibility: "public"}
      assert {:ok, inserted_tag} = Tags.insert(attrs)

      assert fetched_tag = Repo.get(Tag, inserted_tag.uuid)
      assert fetched_tag.name_slug == inserted_tag.name_slug
    end

    test "should fail when inserting tag with same name_slug" do
      original_attrs = %{name: "Open space", category: "realty", visibility: "public"}
      assert {:ok, _} = Tags.insert(original_attrs)

      duplicate_attrs = %{name: "Open Space", category: "infrastructure", visibility: "public"}
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
