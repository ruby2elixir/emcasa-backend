defmodule Re.UtitsTest do
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
      suites: 1
    }

    test "insert new unit" do
      development = insert(:development)

      assert {:ok, inserted_unit} = Units.insert(@insert_unit_params, development)

      retrieved_unit = Repo.get(Unit, inserted_unit.uuid)

      assert retrieved_unit == inserted_unit
      assert retrieved_unit.development_uuid == development.uuid
    end
  end
end
