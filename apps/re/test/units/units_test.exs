defmodule Re.UnitsTest do
  use Re.ModelCase

  alias Re.{
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
  end
end
