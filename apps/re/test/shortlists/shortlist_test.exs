defmodule Re.ShortlistTest do
  use Re.ModelCase

  alias Re.Shortlist

  test "changeset with valid attributes" do
    attrs = %{opportunity_id: "0x01"}

    changeset = Shortlist.changeset(%Shortlist{}, attrs)

    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Shortlist.changeset(%Shortlist{}, %{})

    refute changeset.valid?

    assert Keyword.get(changeset.errors, :opportunity_id) ==
             {"can't be blank", [validation: :required]}
  end
end
