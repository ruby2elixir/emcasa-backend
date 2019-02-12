defmodule Re.Highlights.ScoresTest do
  use Re.ModelCase

  alias Re.Listings.Highlights.Scores

  describe "calculate_recency_score/2" do
    test "return the id normalized by max value" do
      assert 0.5 == Scores.calculate_recency_score(%{id: 100}, 200)
    end

    test "division by zero always return zero" do
      assert 0 == Scores.calculate_recency_score(%{id: 100}, 0)
    end

    test "limit division to one" do
      assert 1 == Scores.calculate_recency_score(%{id: 100}, 10)
    end
  end

  describe "calculate_price_per_area_score/2" do
    test "should return the score price per area for a known neighborhood" do
      params = %{price: 100, area: 50, address: %{neighborhood_slug: "copacabana"}}
      average_price_by_neighborhood = %{"copacabana" => 2.2}
      assert 1.1 == Scores.calculate_price_per_area_score(params, average_price_by_neighborhood)
    end

    test "should return 0 as score price per area for a unknown neighborhood" do
      params = %{price: 100, area: 50, address: %{neighborhood_slug: "invalid"}}
      average_price_by_neighborhood = %{"copacabana" => 2.2}
      assert 0 == Scores.calculate_price_per_area_score(params, average_price_by_neighborhood)
    end

    test "should return 0 as score price per area for priceless" do
      params = %{price: 0, area: 50}
      assert 0 == Scores.calculate_price_per_area_score(params, %{})
    end

    test "should return 0 as score price per area for arealess" do
      params = %{price: 100, area: 0}
      assert 0 == Scores.calculate_price_per_area_score(params, %{})
    end

    test "should return 0 as score price per area for priceless and arealess" do
      params = %{price: 0, area: 0}
      assert 0 == Scores.calculate_price_per_area_score(params, %{})
    end
  end
end
