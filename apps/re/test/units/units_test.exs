defmodule Re.UtitsTest do
  use Re.ModelCase

  alias Re.{
    Listing,
    Unit,
    Units
  }

  import Re.Factory

  describe "insert/2" do
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

    test "insert new unit" do
      development = insert(:development)
      listing = insert(:listing, development_uuid: development.uuid)

      assert {:ok, inserted_unit} = Units.insert(@insert_unit_params, development, listing)

      retrieved_unit = Repo.get(Unit, inserted_unit.uuid)

      assert retrieved_unit == inserted_unit
      assert retrieved_unit.development_uuid == development.uuid
      assert retrieved_unit.listing_id == listing.id
    end

    test "replace listing price by unit price when unit price is lower than listing price" do
      development = insert(:development)
      listing = insert(:listing, price: 1_000_000, development_uuid: development.uuid)

      assert {:ok, inserted_unit} = Units.insert(@insert_unit_params, development, listing)

      listing = Repo.get(Listing, listing.id)

      assert listing.price == 500_000
    end

    test "doesn't update listing price when unit price is higher than listing price" do
      development = insert(:development)
      listing = insert(:listing, price: 400_000, development_uuid: development.uuid)

      assert {:ok, inserted_unit} = Units.insert(@insert_unit_params, development, listing)

      listing = Repo.get(Listing, listing.id)

      assert listing.price == 400_000
    end

    test "doesn't update listing price when unit is invalid" do
      development = insert(:development)
      listing = insert(:listing, price: 400_000, development_uuid: development.uuid)
      invalid_attrs = Map.delete(@insert_unit_params, :price)

      assert {:error, _} = Units.insert(invalid_attrs, development, listing)

      listing = Repo.get(Listing, listing.id)

      assert listing.price == 400_000
    end
  end
end
