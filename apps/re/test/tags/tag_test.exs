defmodule Re.TagTest do
  use Re.ModelCase

  alias Re.Tag

  test "changeset with valid attributes" do
    attrs = %{name: "Open space", category: "infrastructure", visibility: "public"}

    changeset = Tag.changeset(%Tag{}, attrs)

    assert changeset.valid?
    assert changeset.changes.name_slug == "open-space"
    assert changeset.changes.uuid != nil
  end

  test "changeset with invalid attributes" do
    attrs = %{name: "Varanda gourmet", category: "invalid-one", visiblity: "public"}

    changeset = Tag.changeset(%Tag{}, attrs)

    refute changeset.valid?

    assert Keyword.get(changeset.errors, :category) ==
             {"is invalid",
              [
                validation: :inclusion,
                enum: ~w(infrastructure location realty view concierge ops)
              ]}
  end

  test "changeset with missing attributes" do
    attrs = %{category: "infrastructure"}

    changeset = Tag.changeset(%Tag{}, attrs)

    refute changeset.valid?
  end
end
