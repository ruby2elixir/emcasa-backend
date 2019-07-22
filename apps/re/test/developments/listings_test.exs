defmodule Re.Developments.ListingsTest do
  @moduledoc false

  use Re.ModelCase

  alias Re.Developments.Listings

  import Re.Factory

  describe "insert/2" do
    @insert_listing_params %{
      "type" => "Apartamento",
      "description" => "Awesome new brand building",
      "is_exportable" => true,
      "price" => 1_000_000,
      "area" => 100
    }

    test "should insert development listing" do
      address = insert(:address)
      development = insert(:development, address_id: address.id)

      assert {:ok, inserted_listing} =
               Listings.insert(@insert_listing_params,
                 address: address,
                 development: development
               )

      assert retrieved_listing = Repo.get(Re.Listing, inserted_listing.id)
      assert retrieved_listing.uuid
      assert retrieved_listing.development_uuid == development.uuid
      assert retrieved_listing.address_id == address.id
      assert retrieved_listing.is_exportable == true
      assert retrieved_listing.price == 1_000_000
      assert retrieved_listing.area == 100
    end
  end

  describe "listing_params_from_unit/2" do
    test "should parse unit and development into listing" do
      development = build(:development)
      unit = build(:unit, development: development)
      listing = Listings.listing_params_from_unit(unit, development)

      assert unit.price == listing.price
      assert unit.area == listing.area
      assert unit.rooms == listing.rooms
      assert unit.bathrooms == listing.bathrooms
      assert unit.garage_spots == listing.garage_spots
      assert listing.garage_type == listing.garage_type
      assert unit.suites == listing.suites
      assert unit.complement == listing.complement
      assert unit.floor == listing.floor
      assert unit.status == listing.status
      assert unit.property_tax == listing.property_tax
      assert unit.maintenance_fee == listing.maintenance_fee
      assert unit.balconies == listing.balconies
      assert unit.restrooms == listing.restrooms

      assert development.description == listing.description
      assert development.floor_count == listing.floor_count
      assert development.units_per_floor == listing.unit_per_floor
      assert development.elevators == listing.elevators

      assert listing.type == "Apartamento"
      assert listing.is_release == true
      assert listing.is_exportable == false
    end
  end

  describe "typologies/1" do
    test "should list all valid typologies" do
      development = insert(:development)
      typology_params = %{rooms: 2, area: 100, development: development}
      insert(:listing, Map.merge(%{status: "active", price: 500_000}, typology_params))
      insert(:listing, Map.merge(%{status: "active", price: 550_000}, typology_params))
      insert(:listing, Map.merge(%{status: "inactive", price: 600_000}, typology_params))

      assert [
               %{
                 rooms: 2,
                 area: 100,
                 min_price: 500_000,
                 max_price: 550_000,
                 unit_count: 2,
                 development_uuid: development.uuid
               }
             ] == Listings.typologies([development.uuid])
    end
  end
end
