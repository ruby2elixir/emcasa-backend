defmodule Re.Statistics.ListingVisualizationTest do
  use Re.ModelCase

  alias Re.Statistics.ListingVisualization

  import Re.Factory

  test "changeset with user_id" do
    listing = insert(:listing)
    user = insert(:user)

    changeset =
      ListingVisualization.changeset(%ListingVisualization{}, %{
        listing_id: listing.id,
        user_id: user.id
      })

    assert changeset.valid?
  end

  test "changeset without user_id" do
    listing = insert(:listing)

    changeset =
      ListingVisualization.changeset(%ListingVisualization{}, %{
        listing_id: listing.id,
        details: "some details"
      })

    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ListingVisualization.changeset(%ListingVisualization{}, %{})
    refute changeset.valid?
  end
end
