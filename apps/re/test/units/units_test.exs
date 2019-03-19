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
      suites: 1,
      dependencies: 0
    }

    test "insert new unit" do
      assert {:ok, inserted_unit} = Units.insert(@insert_unit_params, nil)
      assert inserted_unit == Repo.get(Unit, inserted_unit.uuid)
    end
  end
end
