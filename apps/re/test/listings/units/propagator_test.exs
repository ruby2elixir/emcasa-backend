defmodule Re.Listings.Units.PropagatorTest do
  use Re.ModelCase

  alias Re.Listings.Units.Propagator
  import Re.Factory

  describe "update_listing/2" do
    @insert_unit_params %{
      complement: "201",
      price: 500_000,
      rooms: 3,
      bathrooms: 1,
      area: 100,
      garage_spots: 1,
      garage_type: "contract",
      dependencies: 0,
      suites: 1,
      status: "active"
    }

    test "replace listing price by unit price when unit price is lower than listing price" do
      development = insert(:development)
      listing = insert(:listing, price: 1_000_000, development_uuid: development.uuid)
      new_unit = insert(:unit, @insert_unit_params)

      assert {:ok, listing} = Propagator.update_listing(listing, new_unit)
      assert listing.price == 500_000
    end

    test "replace listing price by unit price when listing price is nil" do
      development = insert(:development)
      listing = insert(:listing, price: nil, development_uuid: development.uuid)
      new_unit = insert(:unit, @insert_unit_params)

      assert {:ok, listing} = Propagator.update_listing(listing, new_unit)
      assert listing.price == 500_000
    end

    test "doesn't update listing price when unit price is higher than listing price" do
      development = insert(:development)
      listing = insert(:listing, price: 400_000, development_uuid: development.uuid)
      new_unit = insert(:unit, @insert_unit_params)

      assert {:ok, listing} = Propagator.update_listing(listing, new_unit)
      assert listing.price == 400_000
    end
  end
end
