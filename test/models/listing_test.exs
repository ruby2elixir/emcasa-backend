defmodule ReWeb.ListingTest do
  use Re.ModelCase

  alias ReWeb.Listing

  @valid_attrs %{description: "some content", name: "some content", price: 1_000_000, rooms: 4, area: 150, garage_spots: 2}
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
