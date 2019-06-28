defmodule Re.Developments.MirrorTest do
  use Re.ModelCase

  import Re.{
    Factory
  }

  alias Re.{
    Developments.Mirror
  }

  describe "mirror_unit_update_to_listing/1" do
    test "update associated listing with unit informations" do
      address = insert(:address)
      development = insert(:development, address: address)
      %{uuid: uuid} = unit = insert(:unit, development: development)
      insert(:listing, units: [unit], development: development)

      assert {:ok, %Re.Listing{} = listing} = Mirror.mirror_unit_update_to_listing(uuid)

      assert listing.area == unit.area
      assert listing.price == unit.price
      assert listing.rooms == unit.rooms
      assert listing.bathrooms == unit.bathrooms
      assert listing.garage_spots == unit.garage_spots
      assert listing.garage_type == unit.garage_type
      assert listing.suites == unit.suites
      assert listing.complement == unit.complement
      assert listing.floor == unit.floor
      assert listing.matterport_code == unit.matterport_code
      assert listing.property_tax == unit.property_tax
      assert listing.maintenance_fee == unit.maintenance_fee
      assert listing.balconies == unit.balconies
      assert listing.restrooms == unit.restrooms
      assert listing.is_exportable == unit.is_exportable
    end
  end
end
