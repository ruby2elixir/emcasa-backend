defmodule Re.UnitsTest do
  use Re.ModelCase

  alias Re.{
    Listing,
    Developments.Units.Server,
    Unit,
    Units
  }

  import Re.Factory

  @unit_attrs %{
    complement: "201",
    price: 500_000,
    property_tax: 5_000.0,
    maintenance_fee: 500.0,
    floor: "2",
    rooms: 3,
    bathrooms: 1,
    restrooms: 1,
    area: 100,
    garage_spots: 1,
    garage_type: "contract",
    suites: 1,
    dependencies: 1,
    balconies: 1,
    status: "active"
  }

  describe "insert/2" do
    test "insert new unit" do
      development = insert(:development)
      listing = insert(:listing, development_uuid: development.uuid)

      assert {:ok, inserted_unit} = Units.insert(@unit_attrs, development, listing)

      retrieved_unit = Repo.get(Unit, inserted_unit.uuid)

      assert retrieved_unit == inserted_unit
      assert retrieved_unit.development_uuid == development.uuid
      assert retrieved_unit.listing_id == listing.id
    end

    test "update listing with unit attributes when unit is inserted" do
      Server.start_link()
      development = insert(:development)

      {:ok, listing} =
        Re.Repo.insert(%Re.Listing{}, development_uuid: development.uuid, price: 1_000_000)

      assert {:ok, inserted_unit} = Units.insert(@unit_attrs, development, listing)

      GenServer.call(Server, :inspect)

      listing = Repo.get(Listing, listing.id)
      assert listing.complement
      assert listing.price
      assert listing.property_tax
      assert listing.maintenance_fee
      assert listing.floor
      assert listing.rooms
      assert listing.bathrooms
      assert listing.restrooms
      assert listing.area
      assert listing.garage_spots
      assert listing.garage_type
      assert listing.suites
      assert listing.dependencies
      assert listing.balconies
    end
  end

  describe "update/2" do
    test "update listing with unit attributes when unit is updated" do
      Server.start_link()
      development = insert(:development)
      {:ok, listing} = Re.Repo.insert(%Re.Listing{}, development_uuid: development.uuid)
      unit = insert(:unit, development_uuid: development.uuid)

      assert {:ok, _updated_unit} = Units.update(unit, @unit_attrs, development, listing)

      GenServer.call(Server, :inspect)

      listing = Repo.get(Listing, listing.id)
      assert listing.complement
      assert listing.price
      assert listing.property_tax
      assert listing.maintenance_fee
      assert listing.floor
      assert listing.rooms
      assert listing.bathrooms
      assert listing.restrooms
      assert listing.area
      assert listing.garage_spots
      assert listing.garage_type
      assert listing.suites
      assert listing.dependencies
      assert listing.balconies
    end
  end
end
