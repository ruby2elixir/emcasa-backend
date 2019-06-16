defmodule ReIntegrations.OruloTest do
  @moduledoc false

  import Re.CustomAssertion
  import ReIntegrations.Factory

  use ReIntegrations.ModelCase

  alias ReIntegrations.{
    Orulo,
    Orulo.JobQueue,
    Repo
  }

  alias Ecto.Multi

  describe "get_building_payload/2" do
    test "create o new job with to sync development" do
      assert {:ok, _} = Orulo.get_building_payload(100)
      assert Repo.one(JobQueue)
    end

    test "doesn't create a job if building payload already exists for orulo id" do
      insert(:building_payload, external_id: 100)
      assert {:error, _} = Orulo.get_building_payload(100)
      assert [] == Repo.all(JobQueue)
    end
  end

  describe "multi_building_payload_insert/2" do
    test "create new building" do
      params = %{external_id: 666, payload: %{test: "building_payload"}}

      assert {:ok, %{building: inserted_building}} =
               Orulo.multi_building_payload_insert(Multi.new(), params)

      assert inserted_building.uuid
      assert inserted_building.external_id == 666
      assert inserted_building.payload == %{test: "building_payload"}
    end

    test "enqueue a new parse job" do
      params = %{external_id: 666, payload: %{test: "building_payload"}}
      assert {:ok, _} = Orulo.multi_building_payload_insert(Multi.new(), params)
      assert Repo.one(JobQueue)
    end
  end

  describe "multi_images_payload_insert/2" do
    test "create new image payload" do
      params = %{external_id: 666, payload: %{test: "images_payload"}}

      assert {:ok, %{insert_images_payload: images_payload}} =
               Orulo.multi_images_payload_insert(Multi.new(), params)

      assert images_payload.uuid
      assert images_payload.external_id == 666
      assert images_payload.payload == %{test: "images_payload"}
    end

    test "enqueue a new parse images job" do
      params = %{external_id: 666, payload: %{test: "images_payload"}}
      assert {:ok, _} = Orulo.multi_images_payload_insert(Multi.new(), params)

      assert Repo.one(JobQueue)
    end
  end

  describe "insert_typology_payload/2" do
    test "create new typology payload" do
      params = %{building_id: "666", payload: %{test: "typology_payload"}}

      assert {:ok, %{insert_typologies_payload: payload}} =
               Orulo.insert_typologies_payload(Multi.new(), params)

      assert payload.uuid
      assert payload.building_id == "666"
      assert payload.payload == %{test: "typology_payload"}

      JobQueue
      |> Repo.all()
      |> assert_enqueued_job("fetch_units")
    end
  end

  describe "insert_unit_payloads/2" do
    test "create new unit payloads" do
      params = %{
        building_id: "666",
        typology_id: "1",
        payload: %{test: "typology_payload"}
      }

      assert {:ok, %{insert_units_for_typology_1: payload}} =
               Multi.new() |> Orulo.insert_unit_payload(params) |> Repo.transaction()

      assert payload.uuid
      assert payload.building_id == "666"
      assert payload.typology_id == "1"
      assert payload.payload == %{test: "typology_payload"}

      JobQueue
      |> Repo.all()
      |> assert_enqueued_job("process_units")
    end
  end

  describe "get_units/2" do
    test "get units for all typologies" do
      building_id = 1
      typology_ids = [1, 2]

      assert %{
               1 => {:ok, %{body: %{"units" => []}}},
               2 => {:ok, %{body: %{"units" => []}}}
             } ==
               Orulo.get_units(building_id, typology_ids)
    end
  end

  describe "bulk_insert_unit_payload_forking_multi/2" do
    @tag dev: true
    test "get units for all typologies" do
      response = %{
        1 => {:ok, %{body: %{"units" => []}}},
        2 => {:ok, %{body: %{"units" => []}}}
      }

      {:ok,
       %{
         insert_units_for_typology_1: unit_payload_1,
         insert_units_for_typology_2: unit_payload_2
       }} = Orulo.bulk_insert_unit_payload_forking_multi(Multi.new(), response)

      assert unit_payload_1.uuid
      assert unit_payload_1.building_id == "1"
      assert unit_payload_1.typology_id == "1"
      assert unit_payload_1.payload == %{"units" => []}

      assert unit_payload_2.uuid
      assert unit_payload_2.building_id == "1"
      assert unit_payload_2.typology_id == "2"
      assert unit_payload_2.payload == %{"units" => []}

      JobQueue
      |> Repo.all()
      |> assert_enqueued_job("process_units", 2)
    end
  end

  describe "building_already_synced?/2" do
    test "return false when payload does not exists" do
      insert(:building_payload, external_id: 1)
      refute Orulo.building_payload_synced?(2)
    end

    test "return true when payload does exists" do
      insert(:building_payload, external_id: 1)
      assert Orulo.building_payload_synced?(1)
    end
  end
end
