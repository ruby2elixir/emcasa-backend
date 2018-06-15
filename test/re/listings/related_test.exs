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

      assert %{listings: [%{id: ^id2}], remaining_count: 0} = Related.get(listing)
    end

    test "should return a neighborhood and price match listing" do
      listing =
        insert(:listing, address: build(:address, neighborhood: "Copacabana"), price: 100_000)

      %{id: id2} =
        insert(:listing, address: build(:address, neighborhood: "Copacabana"), price: 74_000)

      %{id: id3} =
        insert(:listing, address: build(:address, neighborhood: "Ipanema"), price: 76_000)

      assert %{listings: [%{id: ^id2}, %{id: ^id3}], remaining_count: 0} = Related.get(listing)
    end

    test "should return a room match listing" do
      listing = insert(:listing, address: build(:address, neighborhood: "Copacabana"), rooms: 3)

      %{id: id1} =
        insert(:listing, score: 3, address: build(:address, neighborhood: "Copacabana"), rooms: 4)

      %{id: id2} =
        insert(:listing, score: 4, address: build(:address, neighborhood: "Copacabana"), rooms: 2)

      assert %{listings: [%{id: ^id1}, %{id: ^id2}], remaining_count: 0} = Related.get(listing)
    end

    test "should return a neighborhood and price match listing with nil rooms" do
      listing =
        insert(
          :listing,
          address: build(:address, neighborhood: "Copacabana"),
          price: 100_000,
          rooms: nil
        )

      %{id: id2} =
        insert(:listing, address: build(:address, neighborhood: "Copacabana"), price: 74_000)

      %{id: id3} =
        insert(:listing, address: build(:address, neighborhood: "Ipanema"), price: 76_000)

      assert %{listings: [%{id: ^id2}, %{id: ^id3}], remaining_count: 0} = Related.get(listing)
    end
  end
end
