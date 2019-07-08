defmodule Re.Developments.MirrorTest do
  use Re.ModelCase

  import Re.{
    Factory
  }

  alias Re.{
    Developments.Mirror
  }

  describe "mirror_unit_insert_to_listing/1" do
    test "insert new listing with unit informations" do
      address = insert(:address)
      development = insert(:development, address: address)
      %{uuid: uuid} = unit = insert(:unit, development: development)

      assert {:ok, %Re.Listing{} = listing} = Mirror.mirror_unit_insert_to_listing(uuid)

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

  describe "mirror_development_update_to_listings" do
    test "update associated listing with unit informations" do
      address = insert(:address)
      %{uuid: uuid} = development = insert(:development, address: address)
      unit_1 = insert(:unit, development: development)
      insert(:listing, units: [unit_1], development: development)

      unit_2 = insert(:unit, development: development)
      insert(:listing, units: [unit_2], development: development)

      assert {:ok,
              [
                {:ok, mirrored_listing_1},
                {:ok, mirrored_listing_2}
              ]} = Mirror.mirror_development_update_to_listings(uuid)

      assert development.description == mirrored_listing_1.description
      assert development.floor_count == mirrored_listing_1.floor_count
      assert development.elevators == mirrored_listing_1.elevators
      assert development.units_per_floor == mirrored_listing_1.unit_per_floor

      assert development.description == mirrored_listing_2.description
      assert development.floor_count == mirrored_listing_2.floor_count
      assert development.elevators == mirrored_listing_2.elevators
      assert development.units_per_floor == mirrored_listing_2.unit_per_floor
    end
  end
end
