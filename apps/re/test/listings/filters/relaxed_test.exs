defmodule Re.Listings.Filters.RelaxedTest do
  use Re.ModelCase

  alias Re.Listings.Filters.Relaxed

  import Re.Factory

  describe "get/1" do
    test "should return query with relaxed filters" do
      user = insert(:user)

      %{id: id1} =
        insert(
          :listing,
          price: 1_000_000,
          area: 100,
          liquidity_ratio: 4.0,
          address: build(:address),
          garage_spots: 4
        )

      %{id: id2} =
        insert(
          :listing,
          price: 950_000,
          area: 95,
          liquidity_ratio: 3.0,
          address: build(:address),
          garage_spots: 3
        )

      %{id: id3} =
        insert(
          :listing,
          price: 1_050_000,
          area: 80,
          liquidity_ratio: 2.0,
          address: build(:address),
          garage_spots: 2
        )

      assert %{listings: [%{id: ^id2}, %{id: ^id3}], filters: %{max_price: 1_100_000}} =
               Relaxed.get(%{
                 "max_price" => 1_000_000,
                 "excluded_listing_ids" => [id1],
                 "current_user" => user
               })

      assert %{listings: [%{id: ^id2}, %{id: ^id3}], filters: %{min_price: 900_000}} =
               Relaxed.get(%{
                 "min_price" => 1_000_000,
                 "excluded_listing_ids" => [id1],
                 "current_user" => user
               })

      assert %{listings: [%{id: ^id3}], filters: %{max_area: 99}} =
               Relaxed.get(%{
                 "max_area" => 90,
                 "excluded_listing_ids" => [id2],
                 "current_user" => user
               })

      assert %{listings: [%{id: ^id2}], filters: %{min_area: 90}} =
               Relaxed.get(%{
                 "min_area" => 100,
                 "excluded_listing_ids" => [id1],
                 "current_user" => user
               })

      assert %{listings: [%{id: ^id3}], filters: %{max_area: 99, max_price: 1_100_000}} =
               Relaxed.get(%{
                 "max_area" => 90,
                 "max_price" => 1_000_000,
                 "excluded_listing_ids" => [id1, id2],
                 "current_user" => user
               })

      assert %{listings: [%{id: ^id1}], filters: %{min_area: 85, min_price: 810_000}} =
               Relaxed.get(%{
                 "min_area" => 95,
                 "min_price" => 900_000,
                 "excluded_listing_ids" => [id2, id3],
                 "current_user" => user
               })

      assert %{listings: [%{id: ^id2}, %{id: ^id3}], filters: %{max_garage_spots: 3}} =
               Relaxed.get(%{
                 "max_garage_spots" => 2,
                 "excluded_listing_ids" => [id1],
                 "current_user" => user
               })

      assert %{listings: [%{id: ^id2}, %{id: ^id3}], filters: %{min_garage_spots: 2}} =
               Relaxed.get(%{
                 "min_garage_spots" => 3,
                 "excluded_listing_ids" => [id1],
                 "current_user" => user
               })
    end
  end
end
