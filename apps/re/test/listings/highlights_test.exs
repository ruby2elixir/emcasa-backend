defmodule Re.Listings.HighlightsTest do
  use Re.ModelCase

  alias Re.{
    Listing,
    Listings.Highlights
  }

  import Re.Factory

  describe "get_highlight_listing_ids/2" do
    test "should consider page_size value" do
      insert_list(2, :listing)

      result = Highlights.get_highlight_listing_ids(Listing, %{page_size: 1})
      assert 1 = length(result)
    end

    test "should consider offset value" do
      insert_list(2, :listing)

      result = Highlights.get_highlight_listing_ids(Listing, %{offset: 1})
      assert 1 = length(result)
    end

    test "should sort by updated_at" do
      listing_1 = insert(:listing, updated_at: ~N[2019-01-01 15:30:00.000000])
      listing_2 = insert(:listing, updated_at: ~N[2019-01-01 15:00:00.000000])

      assert [listing_1.id, listing_2.id] == Highlights.get_highlight_listing_ids(Listing, %{})
    end
  end
end
