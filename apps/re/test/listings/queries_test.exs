defmodule Re.Listings.QueriesTest do
  use Re.ModelCase

  alias Re.{
    Listings.Queries,
    Repo
  }

  import Re.Factory

  describe "average_price_per_area_by_neighborhood/0" do
    test "empty result when no listing is available" do
      result =
        Queries.average_price_per_area_by_neighborhood()
        |> Repo.all()

      assert [] == result
    end

    test "average price per area equals to value calculated for the only listing available in neighborhood" do
      data = %{price: 10_000, area: 1_000, address: %{neighborhood_slug: "john-doe"}}

      expected = [
        %{
          average_price_per_area: 10.0,
          neighborhood_slug: data.address.neighborhood_slug
        }
      ]

      insert(:listing, data)

      result =
        Queries.average_price_per_area_by_neighborhood()
        |> Repo.all()

      assert expected == result
    end

    test "average for multiple neighborhoods" do
      data_lapa_1 = %{price: 10_000, area: 1_000, address: %{neighborhood_slug: "lapa"}}
      data_lapa_2 = %{price: 15_000, area: 1_000, address: %{neighborhood_slug: "lapa"}}
      data_perdizes_1 = %{price: 20_000, area: 1_000, address: %{neighborhood_slug: "perdizes"}}
      data_perdizes_2 = %{price: 20_000, area: 2_000, address: %{neighborhood_slug: "perdizes"}}

      expected = [
        %{neighborhood_slug: "lapa", average_price_per_area: 12.5},
        %{neighborhood_slug: "perdizes", average_price_per_area: 15.0}
      ]

      insert(:listing, data_lapa_1)
      insert(:listing, data_lapa_2)
      insert(:listing, data_perdizes_1)
      insert(:listing, data_perdizes_2)

      result =
        Queries.average_price_per_area_by_neighborhood()
        |> Repo.all()

      assert 2 == Enum.count(result)
      assert expected == result
    end
  end

  describe "remaining_count/2" do
    test "get remaining count with tags" do
    end
  end
end
