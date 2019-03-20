defmodule Re.TagsTest do
  use Re.ModelCase

  alias Re.{
    Tag,
    Tags
  }

  import Re.Factory

  describe "insert/1" do
    test "should insert a tag" do
      attrs = %{name: "Varanda gourmet", category: "realty"}
      assert {:ok, inserted_tag} = Tags.insert(attrs)

      assert fetched_tag = Repo.get(Tag, inserted_tag.uuid)
      assert fetched_tag.name_slug == inserted_tag.name_slug
    end

    test "should fail when inserting tag with same name_slug" do
      original_attrs = %{name: "Varanda gourmet", category: "realty"}
      assert {:ok, _} = Tags.insert(original_attrs)

      duplicate_attrs = %{name: "Varanda Gourmet", category: "infrastructure"}
      assert {:error, changeset} = Tags.insert(duplicate_attrs)
      assert Keyword.get(changeset.errors, :name_slug) == {"has already been taken", []}
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
