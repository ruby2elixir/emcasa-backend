defmodule Re.RelatedTest do
  use Re.ModelCase

  alias Re.Listings.Related

  import Re.Factory

  describe "get/1" do
    setup do
      [listing, related1, related2] = insert_list(3, :listing)

      :ets.new(:aliketeller, [:set, :protected, :named_table, read_concurrency: true])
      :ets.insert(:aliketeller, {listing.uuid, [related1.uuid, related2.uuid]})

      {:ok, listing: listing, related1: related1, related2: related2}
    end

    test "should return related listings", %{
      listing: listing,
      related1: %{id: id1},
      related2: %{id: id2}
    } do
      assert %{listings: [%{id: ^id1}, %{id: ^id2}], remaining_count: 0} =
               Related.get(listing.uuid)
    end
  end
end
