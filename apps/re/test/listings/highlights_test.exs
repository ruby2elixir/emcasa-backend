defmodule Re.Listings.HighlightsTest do
  use Re.ModelCase

  alias Re.{
    Listings.Highlights
  }

  import Re.Factory

  describe "get_highlight_listing_ids/2" do
    test "should filter by city and state slug" do
      sao_paulo =
        insert(
          :address,
          city_slug: "sao-paulo",
          state_slug: "sp"
        )

      rio_de_janeiro =
        insert(
          :address,
          city_slug: "rio-de-janeiro",
          state_slug: "rj"
        )

      %{id: id1} = insert(:listing, address_id: sao_paulo.id)

      insert(:listing, address_id: rio_de_janeiro.id)

      filters =
        Map.put(
          %{},
          :filters,
          %{cities_slug: ["sao-paulo"], states_slug: ["sp"]}
        )

      assert [^id1] = Highlights.get_highlight_listing_ids(filters)
    end

    test "should consider page_size value" do
      insert_list(2, :listing)

      result = Highlights.get_highlight_listing_ids(%{page_size: 1})
      assert 1 = length(result)
    end

    test "should consider offset value" do
      insert_list(2, :listing)

      result = Highlights.get_highlight_listing_ids(%{offset: 1})
      assert 1 = length(result)
    end

    test "should sort by updated_at" do
      listing_1 = insert(:listing, updated_at: ~N[2019-01-01 15:30:00.000000])
      listing_2 = insert(:listing, updated_at: ~N[2019-01-01 15:00:00.000000])

      assert [listing_1.id, listing_2.id] == Highlights.get_highlight_listing_ids()
    end
  end
end
