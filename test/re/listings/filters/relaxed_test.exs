defmodule Re.Listings.Filters.RelaxedTest do
  use Re.ModelCase

  alias Re.Listings.Relaxed

  import Re.Factory

  describe "get/1" do
    test "should return query with relaxed filters" do
      %{id: id1} =
        insert(:listing, price: 1_000_000, area: 100, score: 4, address: build(:address))

      %{id: id2} = insert(:listing, price: 950_000, area: 95, score: 3, address: build(:address))

      %{id: id3} =
        insert(:listing, price: 1_050_000, area: 80, score: 2, address: build(:address))

      assert %{listings: [%{id: ^id2}, %{id: ^id3}], filters: %{max_price: 1_100_000}} =
               Relaxed.get(%{"max_price" => 1_000_000, "excluded_listing_ids" => [id1]})

      assert %{listings: [%{id: ^id2}, %{id: ^id3}], filters: %{min_price: 900_000}} =
               Relaxed.get(%{"min_price" => 1_000_000, "excluded_listing_ids" => [id1]})

      assert %{listings: [%{id: ^id3}], filters: %{max_area: 99}} =
               Relaxed.get(%{"max_area" => 90, "excluded_listing_ids" => [id2]})

      assert %{listings: [%{id: ^id2}], filters: %{min_area: 90}} =
               Relaxed.get(%{"min_area" => 100, "excluded_listing_ids" => [id1]})

      assert %{listings: [%{id: ^id3}], filters: %{max_area: 99, max_price: 1_100_000}} =
               Relaxed.get(%{
                 "max_area" => 90,
                 "max_price" => 1_000_000,
                 "excluded_listing_ids" => [id1, id2]
               })

      assert %{listings: [%{id: ^id1}], filters: %{min_area: 85, min_price: 810_000}} =
               Relaxed.get(%{
                 "min_area" => 95,
                 "min_price" => 900_000,
                 "excluded_listing_ids" => [id2, id3]
               })
    end
  end
end
