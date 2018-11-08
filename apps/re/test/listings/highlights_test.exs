defmodule Re.Listings.HighlightsTest do
  use Re.ModelCase

  alias Re.{
    Listings.Highlights,
    Listings.Highlights.Zap,
    Listings.Highlights.ZapSuper,
    Listings.Highlights.Vivareal,
    Repo
  }

  import Re.Factory

  describe "get highlights" do
    test "should return zap highlighted listings" do
      %{id: listing_id} = insert(:listing)
      insert(:zap_highlight, listing_id: listing_id)

      [listing] = Highlights.get_zap_highlights()
      assert listing_id == listing.id
    end

    test "should return zap super highlighted listings" do
      %{id: listing_id} = insert(:listing)
      insert(:zap_super_highlight, listing_id: listing_id)

      [listing] = Highlights.get_zap_super_highlights()
      assert listing_id == listing.id
    end

    test "should return vivareal highlighted listings" do
      %{id: listing_id} = insert(:listing)
      insert(:vivareal_highlight, listing_id: listing_id)

      [listing] = Highlights.get_vivareal_highlights()
      assert listing_id == listing.id
    end
  end

  describe "insert highlights" do
    test "should insert zap highlighted listings" do
      listing = insert(:listing)

      {:ok, _highlight} = Highlights.insert_zap_highlight(listing)

      assert Repo.get_by(Zap, listing_id: listing.id)
    end

    test "should not insert zap highlighted listings when there's one for that listing" do
      listing = insert(:listing)
      insert(:zap_highlight, listing_id: listing.id)

      {:error, _} = Highlights.insert_zap_highlight(listing)

      assert Repo.get_by(Zap, listing_id: listing.id)
    end

    test "should insert zap super highlighted listings" do
      listing = insert(:listing)

      {:ok, _highlight} = Highlights.insert_zap_super_highlight(listing)

      assert Repo.get_by(ZapSuper, listing_id: listing.id)
    end

    test "should not insert zap super highlighted listings when there's one for that listing" do
      listing = insert(:listing)
      insert(:zap_super_highlight, listing_id: listing.id)

      {:error, _} = Highlights.insert_zap_super_highlight(listing)

      assert Repo.get_by(ZapSuper, listing_id: listing.id)
    end

    test "should insert vivareal highlighted listings" do
      listing = insert(:listing)

      {:ok, _highlight} = Highlights.insert_vivareal_highlight(listing)

      assert Repo.get_by(Vivareal, listing_id: listing.id)
    end

    test "should not insert vivareal highlighted listings when there's one for that listing" do
      listing = insert(:listing)
      insert(:vivareal_highlight, listing_id: listing.id)

      {:error, _} = Highlights.insert_vivareal_highlight(listing)

      assert Repo.get_by(Vivareal, listing_id: listing.id)
    end
  end
end
