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

    test "average equals only listing for neighborhood" do
      data = %{price: 10_000, area: 1_000, address: %{neighborhood_slug: "john-doe"}}

      expected = [
        %{
          average_price_per_area: data.price / data.area,
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
      data_johndoe_1 = %{price: 10_000, area: 1_000, address: %{neighborhood_slug: "john-doe"}}
      data_johndoe_2 = %{price: 15_000, area: 1_000, address: %{neighborhood_slug: "john-doe"}}
      data_janedoe_1 = %{price: 20_000, area: 1_000, address: %{neighborhood_slug: "jane-doe"}}
      data_janedoe_2 = %{price: 20_000, area: 2_000, address: %{neighborhood_slug: "jane-doe"}}

      expected = [
        %{neighborhood_slug: "jane-doe", average_price_per_area: 15.0},
        %{neighborhood_slug: "john-doe", average_price_per_area: 12.5}
      ]

      insert(:listing, data_johndoe_1)
      insert(:listing, data_johndoe_2)
      insert(:listing, data_janedoe_1)
      insert(:listing, data_janedoe_2)

      result =
        Queries.average_price_per_area_by_neighborhood()
        |> Repo.all()

      assert 2 == Enum.count(result)
      assert expected == result
    end
  end
end
