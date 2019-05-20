defmodule Re.UnitsTest do
  use Re.ModelCase

  alias Re.{
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

      assert {:ok, %{add_unit: inserted_unit, units_job: _}} =
               Units.insert(@unit_attrs, development)

      retrieved_unit = Repo.get(Unit, inserted_unit.uuid)

      assert retrieved_unit == inserted_unit
      assert retrieved_unit.development_uuid == development.uuid
    end

    @tag dev: true
    test "create new add_unit job" do
      development = insert(:development)

      assert {:ok, _} = Units.insert(@unit_attrs, development)

      assert Repo.one(Re.Developments.JobQueue)
    end
  end
end
