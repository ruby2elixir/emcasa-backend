defmodule Re.Listings.QueriesTest do
  use Re.ModelCase

  alias Re.{
    Listings.Filters,
    Listing,
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
    test "remaining count with single tag search should bring correct number of listings" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")
      insert(:listing, tags: [tag_1])
      insert(:listing, tags: [tag_1])

      result =
        Listing
        |> Filters.apply(%{tags_uuid: [tag_1.uuid]})
        |> Queries.remaining_count()
        |> Repo.one()

      assert 2 == result
    end

    test "remaining count with multi tag search should bring correct number of listings, despite many to many relation" do
      tag_1 = insert(:tag, name: "Tag 1", name_slug: "tag-1")
      tag_2 = insert(:tag, name: "Tag 2", name_slug: "tag-2")
      insert(:listing, tags: [tag_1, tag_2])
      insert(:listing, tags: [tag_1, tag_2])

      result =
        Listing
        |> Filters.apply(%{tags_uuid: [tag_1.uuid, tag_2.uuid]})
        |> Queries.remaining_count()
        |> Repo.one()

      assert 2 == result
    end
  end

  describe "order_by/2" do
    test "order listings by price per area" do
      %{id: listing_id_1} =
        insert(:listing, price: 20, area: 1, price_per_area: 20, status: "active")

      %{id: listing_id_2} =
        insert(:listing, price: 15, area: 1, price_per_area: 15, status: "active")

      %{id: listing_id_3} =
        insert(:listing, price: 10, area: 1, price_per_area: 10, status: "active")

      result =
        Queries.active()
        |> Queries.order_by(%{order_by: [%{field: :price_per_area, type: :asc}]})
        |> Repo.all()
        |> Enum.map(& &1.id)

      assert [listing_id_3, listing_id_2, listing_id_1] == result
    end

    test "order by score by default with nils on last" do
      %{id: listing_id_1} = insert(:listing, liquidity_ratio: nil)
      %{id: listing_id_2} = insert(:listing, liquidity_ratio: -1.0)
      %{id: listing_id_3} = insert(:listing, liquidity_ratio: 1.0)

      result =
        Queries.active()
        |> Queries.order_by()
        |> Repo.all()
        |> Enum.map(& &1.id)

      assert [listing_id_3, listing_id_2, listing_id_1] == result
    end
  end
end
