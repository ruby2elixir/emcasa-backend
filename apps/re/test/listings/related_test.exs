defmodule Re.RelatedTest do
  use Re.ModelCase

  alias Re.{
    AlikeTeller,
    Listings.Related
  }

  import Re.Factory

  describe "get/1" do
    setup do
      [listing, related1, related2] = insert_list(3, :listing)

      AlikeTeller.create_ets_table()
      AlikeTeller.insert(listing.uuid, [related1.uuid, related2.uuid])

      {:ok, listing: listing, related1: related1, related2: related2}
    end

    test "should return related listings", %{
      listing: listing,
      related1: %{id: id1},
      related2: %{id: id2}
    } do
      assert {:ok, %{listings: [%{id: ^id1}, %{id: ^id2}], remaining_count: 0}} =
               Related.get(listing.uuid)
    end

    test "should return empty when there's not related" do
      listing = insert(:listing)

      assert {:ok, nil} = Related.get(listing.uuid)
    end
  end
end
