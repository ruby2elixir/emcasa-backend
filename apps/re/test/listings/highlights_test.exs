defmodule Re.Listings.HighlightsTest do
  use Re.ModelCase

  alias Re.{
    Address,
    Listings.Highlights
  }

  import Re.Factory

  @valid_attributes_rj %{
    price: 1_999_999,
    rooms: 3,
    garage_spots: 1,
    area: 100,
    address: %Address{
      neighborhood_slug: "botafogo",
      city_slug: "rio-de-janeiro",
      state_slug: "rj"
    }
  }

  @valid_attributes_sp %{
    price: 2_000_000,
    rooms: 3,
    garage_spots: 2,
    area: 100,
    address: %Address{
      neighborhood_slug: "perdizes",
      city_slug: "sao-paulo",
      state_slug: "sp"
    }
  }

  describe "get_highlight_listing_ids/2" do
    test "should filter by city and state slug" do
      %{id: id1} = insert(:listing, @valid_attributes_sp)

      insert(:listing, @valid_attributes_rj)

      filters =
        Map.put(
          %{},
          :filters,
          %{cities_slug: ["sao-paulo"], states_slug: ["sp"]}
        )

      assert [^id1] = Highlights.get_highlight_listing_ids(filters)
    end

    test "should consider page_size value" do
      insert_list(2, :listing, @valid_attributes_rj)

      result = Highlights.get_highlight_listing_ids(%{page_size: 1})
      assert 1 = length(result)
    end

    test "should consider offset value" do
      insert_list(2, :listing, @valid_attributes_rj)

      result = Highlights.get_highlight_listing_ids(%{offset: 1})
      assert 1 = length(result)
    end

    test "should consider listings with prices bellow 2 millions" do
      %{id: listing_id_valid} = insert(:listing, @valid_attributes_rj)

      invalid_attributes = Map.merge(@valid_attributes_rj, %{price: 2_000_001})
      insert(:listing, invalid_attributes)

      assert [listing_id_valid] == Highlights.get_highlight_listing_ids()
    end

    test "should consider listings with less than 4 rooms" do
      %{id: listing_id_valid} = insert(:listing, @valid_attributes_rj)

      invalid_attributes = Map.merge(@valid_attributes_rj, %{rooms: 4})
      insert(:listing, invalid_attributes)

      assert [listing_id_valid] == Highlights.get_highlight_listing_ids()
    end

    test "should consider listings with more than 1 garage spot" do
      %{id: listing_id_valid} = insert(:listing, @valid_attributes_rj)

      invalid_attributes = Map.merge(@valid_attributes_rj, %{garage_spots: 0})
      insert(:listing, invalid_attributes)

      assert [listing_id_valid] == Highlights.get_highlight_listing_ids()
    end

    test "should only consider listings in selected neighborhoods in rio de janeiro" do
      %{id: listing_id_valid} = insert(:listing, @valid_attributes_rj)

      invalid_attributes = Map.merge(

        @valid_attributes_rj,
        %{
          address: %Address{
            neighborhood_slug: "lalaland",
            city_slug: "rio-de-janeiro",
            state_slug: "rj"
          }
        }
      )
      insert(:listing, invalid_attributes)

      assert [listing_id_valid] == Highlights.get_highlight_listing_ids()
    end

    test "should only consider listings in selected neighborhoods in sao paulo" do
      %{id: listing_id_valid} = insert(:listing, @valid_attributes_sp)

      invalid_attributes = Map.merge(
        @valid_attributes_sp,
        %{
          address: %Address{
            neighborhood_slug: "lalaland",
            city_slug: "sao-paulo",
            state_slug: "sp"
          }
        }
      )
      insert(:listing, invalid_attributes)

      assert [listing_id_valid] == Highlights.get_highlight_listing_ids()
    end

    test "should sort by recents" do
      [%{id: listing_id_1}, %{id: listing_id_2}] = insert_list(2, :listing, @valid_attributes_rj)

      assert [listing_id_2, listing_id_1] == Highlights.get_highlight_listing_ids()
    end
  end

  describe "calculate_recency_score/2" do
    test "return the id normalized by max value" do
      assert 0.5 == Highlights.calculate_recency_score(%{id: 100}, 200)
    end

    test "division by zero always return zero" do
      assert 0 == Highlights.calculate_recency_score(%{id: 100}, 0)
    end

    test "limit division to one" do
      assert 1 == Highlights.calculate_recency_score(%{id: 100}, 10)
     end
  end

  describe "calculate_price_per_area_score/2" do
    test "should return the score price per area for a known neighborhood" do
      params = %{price: 100, area: 50, address: %{neighborhood_slug: "copacabana"}}
      average_price_by_neighborhood = %{"copacabana" => 2.2}
      assert 1.1 == Highlights.calculate_price_per_area_score(params, average_price_by_neighborhood)
    end

    test "should return 0 as score price per area for a unknown neighborhood" do
      params = %{price: 100, area: 50, address: %{neighborhood_slug: "invalid"}}
      average_price_by_neighborhood = %{"copacabana" => 2.2}
      assert 0 == Highlights.calculate_price_per_area_score(params, average_price_by_neighborhood)
    end

    test "should return 0 as score price per area for priceless" do
      params = %{price: 0, area: 50}
      assert 0 == Highlights.calculate_price_per_area_score(params, %{})
    end

    test "should return 0 as score price per area for arealess" do
      params = %{price: 100, area: 0}
      assert 0 == Highlights.calculate_price_per_area_score(params, %{})
    end

    test "should return 0 as score price per area for priceless and arealess" do
      params = %{price: 0, area: 0}
      assert 0 == Highlights.calculate_price_per_area_score(params, %{})
    end
  end
end
