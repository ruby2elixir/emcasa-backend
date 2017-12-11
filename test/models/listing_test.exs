defmodule ReWeb.ListingTest do
  use Re.ModelCase

  alias ReWeb.Listing

  @valid_attrs %{type: "Apartamento", complement: "100", description: "some content",  price: 1_000_000, floor: "3", rooms: 4, bathrooms: 4, area: 150, garage_spots: 2, score: 4, matterport_code: ""}
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
