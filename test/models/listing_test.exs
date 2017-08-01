defmodule ReWeb.ListingTest do
  use Re.ModelCase

  alias ReWeb.Listing

  @valid_attrs %{description: "some content", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Listing.changeset(%Listing{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Listing.changeset(%Listing{}, @invalid_attrs)
    refute changeset.valid?
  end
end
