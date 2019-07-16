defmodule Re.RelatedTest do
  use Re.ModelCase

  alias Re.Listings.Related

  import Re.Factory

  describe "get/1" do
    test "should return a neighborhood match listing" do
      listing =
        insert(:listing,
          address: build(:address, city: "Rio de Janeiro", neighborhood: "Copacabana"),
          price: 100_000
        )

      %{id: id2} =
        insert(:listing,
          address: build(:address, city: "Rio de Janeiro", neighborhood: "Copacabana"),
          price: 74_999
        )

      assert %{listings: [%{id: ^id2}], remaining_count: 0} = Related.get(listing)
    end

    test "should return a neighborhood and price match listing" do
      listing =
        insert(:listing,
          address: build(:address, city: "Rio de Janeiro", neighborhood: "Copacabana"),
          price: 100_000
        )

      %{id: id2} =
        insert(:listing,
          address: build(:address, city: "Rio de Janeiro", neighborhood: "Copacabana"),
          price: 74_000,
          liquidity_ratio: 4.0
        )

      %{id: id3} =
        insert(:listing,
          address: build(:address, city: "Rio de Janeiro", neighborhood: "Ipanema"),
          price: 76_000,
          liquidity_ratio: 3.0
        )

      assert %{listings: [%{id: ^id2}, %{id: ^id3}], remaining_count: 0} = Related.get(listing)
    end

    test "should return a room match listing" do
      listing =
        insert(:listing,
          address: build(:address, city: "Rio de Janeiro", neighborhood: "Copacabana"),
          rooms: 3
        )

      %{id: id1} =
        insert(:listing,
          liquidity_ratio: 3.0,
          address: build(:address, city: "Rio de Janeiro", neighborhood: "Copacabana"),
          rooms: 4,
          liquidity_ratio: 4.0
        )

      %{id: id2} =
        insert(:listing,
          liquidity_ratio: 4.0,
          address: build(:address, city: "Rio de Janeiro", neighborhood: "Copacabana"),
          rooms: 2,
          liquidity_ratio: 3.0
        )

      assert %{listings: [%{id: ^id1}, %{id: ^id2}], remaining_count: 0} = Related.get(listing)
    end

    test "should return a neighborhood and price match listing with nil rooms" do
      listing =
        insert(
          :listing,
          address: build(:address, city: "Rio de Janeiro", neighborhood: "Copacabana"),
          price: 100_000,
          rooms: nil
        )

      %{id: id2} =
        insert(:listing,
          address: build(:address, city: "Rio de Janeiro", neighborhood: "Copacabana"),
          price: 74_000,
          liquidity_ratio: 4.0
        )

      %{id: id3} =
        insert(:listing,
          address: build(:address, city: "Rio de Janeiro", neighborhood: "Ipanema"),
          price: 76_000,
          liquidity_ratio: 3.0
        )

      assert %{listings: [%{id: ^id2}, %{id: ^id3}], remaining_count: 0} = Related.get(listing)
    end

    test "should return a neighborhood match listing with nil price" do
      listing =
        insert(
          :listing,
          address: build(:address, city: "Rio de Janeiro", neighborhood: "Copacabana"),
          price: nil,
          rooms: 3
        )

      %{id: id2} =
        insert(
          :listing,
          address: build(:address, city: "Rio de Janeiro", neighborhood: "Copacabana"),
          price: 74_000,
          rooms: 1
        )

      insert(:listing,
        address: build(:address, city: "São Paulo", neighborhood: "Ipanema"),
        price: 76_000,
        rooms: 1
      )

      assert %{listings: [%{id: ^id2}], remaining_count: 0} = Related.get(listing)
    end

    test "should only return listings in the same city" do
      listing =
        insert(:listing,
          address: build(:address, city: "Rio de Janeiro", neighborhood: "Copacabana"),
          price: 100_000
        )

      %{id: id2} =
        insert(:listing,
          address: build(:address, city: "Rio de Janeiro", neighborhood: "Copacabana"),
          price: 74_999
        )

      insert(:listing,
        address: build(:address, city: "São Paulo", neighborhood: "Copacabana"),
        price: 74_999
      )

      assert %{listings: [%{id: ^id2}], remaining_count: 0} = Related.get(listing)
    end
  end
end
