defmodule Re.TagTest do
  use Re.ModelCase

  alias Re.Tag

  test "changeset with valid attributes" do
    attrs = %{name: "Varanda gourmet", category: "infrastructure"}

    changeset = Tag.changeset(%Tag{}, attrs)

    assert changeset.valid?
    assert changeset.changes.name_slug == "varanda-gourmet"
    assert changeset.changes.uuid != nil
  end

  test "changeset with invalid attributes" do
    attrs = %{name: "Varanda gourmet", category: "invalid-one"}

    changeset = Tag.changeset(%Tag{}, attrs)

    refute changeset.valid?

    assert Keyword.get(changeset.errors, :category) ==
             {"should be one of: [infrastructure, location, realty]", [validation: :inclusion]}
  end

  test "changeset with missing attributes" do
    attrs = %{category: "infrastructure"}

    changeset = Tag.changeset(%Tag{}, attrs)

    refute changeset.valid?
  end
end
