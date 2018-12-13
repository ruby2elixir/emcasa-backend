defmodule Re.Listings.HighlightsTest do
  use Re.ModelCase

  alias Re.{
    Listing,
    Listings.Highlights,
    Repo
  }

  import Re.Factory

  describe "get highlights" do
    test "should return zap highlighted listings" do
      %{id: listing_id} = insert(:listing, zap_highlight: true)

      [listing] = Highlights.get_zap_highlights()
      assert listing_id == listing.id
    end

    test "should return zap super highlighted listings" do
      %{id: listing_id} = insert(:listing, zap_super_highlight: true)

      [listing] = Highlights.get_zap_super_highlights()
      assert listing_id == listing.id
    end

    test "should return vivareal highlighted listings" do
      %{id: listing_id} = insert(:listing, vivareal_highlight: true)

      [listing] = Highlights.get_vivareal_highlights()
      assert listing_id == listing.id
    end
  end

  describe "insert highlights" do
    test "should insert zap highlighted listings" do
      listing = insert(:listing)

      {:ok, listing} = Highlights.insert_zap_highlight(listing)

      assert Repo.get(Listing, listing.id).zap_highlight
    end

    test "should not insert zap highlighted listings when there's one for that listing" do
      listing = insert(:listing, zap_highlight: true)

      {:ok, listing} = Highlights.insert_zap_highlight(listing)

      assert Repo.get(Listing, listing.id).zap_highlight
    end

    test "should insert zap super highlighted listings" do
      listing = insert(:listing)

      {:ok, listing} = Highlights.insert_zap_super_highlight(listing)

      assert Repo.get(Listing, listing.id).zap_super_highlight
    end

    test "should not insert zap super highlighted listings when there's one for that listing" do
      listing = insert(:listing, zap_super_highlight: true)

      {:ok, listing} = Highlights.insert_zap_super_highlight(listing)

      assert Repo.get(Listing, listing.id).zap_super_highlight
    end

    test "should insert vivareal highlighted listings" do
      listing = insert(:listing)

      {:ok, listing} = Highlights.insert_vivareal_highlight(listing)

      assert Repo.get(Listing, listing.id).vivareal_highlight
    end

    test "should not insert vivareal highlighted listings when there's one for that listing" do
      listing = insert(:listing, vivareal_highlight: true)

      {:ok, listing} = Highlights.insert_vivareal_highlight(listing)

      assert Repo.get(Listing, listing.id).vivareal_highlight
    end
  end
end
