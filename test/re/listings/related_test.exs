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
        insert(:listing,
          address: build(:address, neighborhood: "Copacabana"),
          price: 74_000,
          score: 4
        )

      %{id: id3} =
        insert(:listing,
          address: build(:address, neighborhood: "Ipanema"),
          price: 76_000,
          score: 3
        )

      assert %{listings: [%{id: ^id2}, %{id: ^id3}], remaining_count: 0} = Related.get(listing)
    end

    test "should return a room match listing" do
      listing = insert(:listing, address: build(:address, neighborhood: "Copacabana"), rooms: 3)

      %{id: id1} =
        insert(:listing,
          score: 3,
          address: build(:address, neighborhood: "Copacabana"),
          rooms: 4,
          score: 4
        )

      %{id: id2} =
        insert(:listing,
          score: 4,
          address: build(:address, neighborhood: "Copacabana"),
          rooms: 2,
          score: 3
        )

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
        insert(:listing,
          address: build(:address, neighborhood: "Copacabana"),
          price: 74_000,
          score: 4
        )

      %{id: id3} =
        insert(:listing,
          address: build(:address, neighborhood: "Ipanema"),
          price: 76_000,
          score: 3
        )

      assert %{listings: [%{id: ^id2}, %{id: ^id3}], remaining_count: 0} = Related.get(listing)
    end

    test "should return a neighborhood match listing with nil price" do
      listing =
        insert(
          :listing,
          address: build(:address, neighborhood: "Copacabana"),
          price: nil,
          rooms: 3
        )

      %{id: id2} =
        insert(
          :listing,
          address: build(:address, neighborhood: "Copacabana"),
          price: 74_000,
          rooms: 1
        )

      insert(:listing, address: build(:address, neighborhood: "Ipanema"), price: 76_000, rooms: 1)

      assert %{listings: [%{id: ^id2}], remaining_count: 0} = Related.get(listing)
    end

    test "should filter out blacklisted listing" do
      user = insert(:user)

      listing =
        insert(:listing, address: build(:address, neighborhood: "Copacabana"), price: 100_000)

      %{id: id2} =
        insert(:listing, address: build(:address, neighborhood: "Copacabana"), price: 74_999)

      listing3 =
        insert(:listing, address: build(:address, neighborhood: "Copacabana"), price: 74_999)

      insert(:listing_blacklist, listing: listing3, user: user)

      assert %{listings: [%{id: ^id2}], remaining_count: 0} =
               Related.get(listing, %{current_user: user})
    end
  end
end
