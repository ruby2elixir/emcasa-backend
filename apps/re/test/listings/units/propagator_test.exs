defmodule Re.Listings.Units.PropagatorTest do
  use Re.ModelCase

  alias Re.Listings.Units.Propagator
  import Re.Factory

  describe "update_listing/2" do
    test "update listing with lower price from price_list" do
      listing = insert(:listing, price: 1_000_000)
      price_list = [400_000, 800_000, 1_200_000]

      assert {:ok, listing} = Propagator.update_listing(listing, price_list)
      assert listing.price == 400_000
    end

    test "doesn't update listing price when price_list is empty" do
      listing = insert(:listing, price: 500_000)

      assert {:ok, listing} = Propagator.update_listing(listing, [])
      assert listing.price == 500_000
    end

    test "keep same listing price when price_list is nil" do
      listing = insert(:listing, price: 500_000)

      assert {:ok, listing} = Propagator.update_listing(listing, nil)
      assert listing.price == 500_000
    end
  end
end
