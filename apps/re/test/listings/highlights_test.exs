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

      %{entries: [listing]} = Highlights.get_zap_highlights()
      assert listing_id == listing.id
    end

    test "should return zap super highlighted listings" do
      %{id: listing_id} = insert(:listing, zap_super_highlight: true)

      %{entries: [listing]} = Highlights.get_zap_super_highlights()
      assert listing_id == listing.id
    end

    test "should return vivareal highlighted listings" do
      %{id: listing_id} = insert(:listing, vivareal_highlight: true)

      %{entries: [listing]} = Highlights.get_vivareal_highlights()
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

  describe "get_highlight_listing_ids/2" do
    test "should consider limit value" do
      insert_list(2, :listing)

      result = Highlights.get_highlight_listing_ids(Listing, %{page_size: 1})
      assert 1 = length(result)
    end

    test "should sort by updated_at" do
      listing_1 = insert(:listing, updated_at: ~N[2019-01-01 15:30:00.000000])
      listing_2 = insert(:listing, updated_at: ~N[2019-01-01 15:00:00.000000])

      assert [listing_1.id, listing_2.id] == Highlights.get_highlight_listing_ids(Listing, %{})
    end
  end
end
