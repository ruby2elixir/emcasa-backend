defmodule Re.UnitsTest do
  @moduledoc false

  use Re.ModelCase

  alias Re.{
    Developments.JobQueue,
    Unit,
    Units
  }

  import Re.CustomAssertion
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
               Units.insert(@unit_attrs, development: development)

      retrieved_unit = Repo.get(Unit, inserted_unit.uuid)

      assert retrieved_unit == inserted_unit
      assert retrieved_unit.development_uuid == development.uuid
    end

    test "create new development job" do
      development = insert(:development)

      assert {:ok, _} = Units.insert(@unit_attrs, development: development)

      assert Repo.one(JobQueue)
    end
  end

  describe "update/2" do
    test "create new mirror_update_unit_to_listing" do
      development = insert(:development)
      unit = insert(:unit)

      Units.update(unit, @unit_attrs, development: development)

      JobQueue
      |> Re.Repo.all()
      |> assert_enqueued_job("mirror_update_unit_to_listing")
    end
  end
end
