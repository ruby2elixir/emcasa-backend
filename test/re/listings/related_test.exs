defmodule Re.RelatedTest do
  use Re.ModelCase

  alias Re.Listings.Related

  import Re.Factory

  describe "get/1" do
    test "should return a neighborhood match listing" do
      listing =
        insert(:listing, address: build(:address, neighborhood: "Copacabana"), price: 100_000)

      %{id: id2} =
        insert(:listing, address: build(:address, neighborhood: "Copacabana"), price: 74_999)

      assert {:ok, [%{id: ^id2}]} = Related.get(listing)
    end

    test "should return a neighborhood and price match listing" do
      listing =
        insert(:listing, address: build(:address, neighborhood: "Copacabana"), price: 100_000)

      %{id: id2} =
        insert(:listing, address: build(:address, neighborhood: "Copacabana"), price: 74_999)

      %{id: id3} =
        insert(:listing, address: build(:address, neighborhood: "Ipanema"), price: 75_001)

      assert {:ok, [%{id: ^id2}, %{id: ^id3}]} = Related.get(listing)
    end

    test "should return a featured listing when there's no related one" do
      %{id: id1} = insert(:listing, address: build(:address, neighborhood: "b"))
      %{id: id2} = insert(:listing, address: build(:address, neighborhood: "b"))
      %{id: id3} = insert(:listing, address: build(:address, neighborhood: "b"))
      %{id: id4} = insert(:listing, address: build(:address, neighborhood: "b"))
      insert(:featured_listing, listing_id: id1, position: 4)
      insert(:featured_listing, listing_id: id2, position: 3)
      insert(:featured_listing, listing_id: id3, position: 2)
      insert(:featured_listing, listing_id: id4, position: 1)

      listing =
        insert(:listing, address: build(:address, neighborhood: "Copacabana"), price: 100_000)

      insert(:listing, address: build(:address, neighborhood: "Botafogo"), price: 130_000)

      assert {:ok, [%{id: ^id4}, %{id: ^id3}, %{id: ^id2}, %{id: ^id1}]} = Related.get(listing)
    end
  end
end
