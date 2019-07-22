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
      assert_enqueued_job(Repo.all(JobQueue), "import_development_from_orulo")
    end

    test "doesn't create a job if building payload already exists for orulo id" do
      insert(:building_payload, external_id: 100)
      assert {:error, _} = Orulo.get_building_payload(100)
      assert [] == Repo.all(JobQueue)
    end
  end

  describe "insert_building_payload/2" do
    test "create new building" do
      assert {:ok, %{insert_building_payload: inserted_building}} =
               Orulo.import_development(Multi.new(), 666)

      assert inserted_building.uuid
      assert inserted_building.external_id == 666
      assert inserted_building.payload == %{"test" => "building_payload"}
      assert_enqueued_job(Repo.all(JobQueue), "parse_building_into_development")
    end
  end

  describe "import_images/2" do
    test "create new image payload" do
      assert {:ok, %{insert_images_payload: images_payload}} =
               Orulo.import_images(Multi.new(), 666)

      assert images_payload.uuid
      assert images_payload.external_id == 666
      assert images_payload.payload == %{"test" => "images_payload"}
      assert_enqueued_job(Repo.all(JobQueue), "parse_images_payloads_into_images")
    end
  end

  describe "import_typologies/2" do
    test "create new typology payload" do
      assert {:ok, %{insert_typologies_payload: payload}} =
               Orulo.import_typologies(Multi.new(), "666")

      assert payload.uuid
      assert payload.building_id == "666"
      assert payload.payload == %{"test" => "typologies_payload"}
      assert_enqueued_job(Repo.all(JobQueue), "fetch_units")
    end
  end

  describe "get_units/2" do
    test "get units for all typologies" do
      building_id = "1"
      typology_ids = ["1", "2"]

      assert %{
               "1" => {:ok, %{body: "{\"units\": []}"}},
               "2" => {:ok, %{body: "{\"units\": []}"}}
             } ==
               Orulo.get_units(building_id, typology_ids)
    end
  end

  describe "bulk_insert_unit_payloads/2" do
    test "get units for all typologies" do
      responses = %{
        "1" => {:ok, %{body: "{\"units\": []}"}},
        "2" => {:ok, %{body: "{\"units\": []}"}}
      }

      building_id = "1"

      {:ok,
       %{
         "insert_units_for_typology_1" => unit_payload_1,
         "insert_units_for_typology_2" => unit_payload_2
       }} = Orulo.bulk_insert_unit_payloads(Multi.new(), building_id, responses)

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
