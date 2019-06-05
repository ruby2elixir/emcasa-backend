defmodule ReIntegrations.Orulo.PayloadsProcessorTest do
  @moduledoc false

  use ReIntegrations.ModelCase

  alias ReIntegrations.{
    Orulo.BuildingPayload,
    Orulo.ImagePayload,
    Orulo.JobQueue,
    Orulo.PayloadsProcessor,
    Repo
  }

  alias Ecto.Multi

  import ReIntegrations.Factory

  describe "insert_development_from_building_payload/1" do
    test "create new address from building" do
      %{uuid: uuid} =
        build(:building)
        |> BuildingPayload.changeset()
        |> Repo.insert!()

      assert {:ok, %{insert_address: new_address}} =
               PayloadsProcessor.insert_development_from_building_payload(Multi.new(), uuid)

      assert new_address.street == "Copacabana"
      assert new_address.street_number == "926"
      assert new_address.neighborhood == "Copacabana"
      assert new_address.city == "Rio de Janeiro"
      assert new_address.state == "RJ"
      assert new_address.lat == -23.5345
      assert new_address.lng == -46.6871
      assert new_address.postal_code == "05021-001"
    end

    test "create new development from building" do
      %{payload: payload = %{"developer" => developer}} = building = build(:building)

      %{uuid: uuid} =
        building
        |> BuildingPayload.changeset()
        |> Repo.insert!()

      assert {:ok, %{insert_development: development}} =
               PayloadsProcessor.insert_development_from_building_payload(Multi.new(), uuid)

      assert development.uuid
      assert development.name == Map.get(payload, "name")
      assert development.description == Map.get(payload, "description")
      assert development.phase == "building"
      assert development.floor_count == Map.get(payload, "number_of_floors")
      assert development.units_per_floor == Map.get(payload, "apts_per_floor")

      assert development.builder == Map.get(developer, "name")
    end

    test "enqueue a new job to fetch images" do
      building = build(:building)

      %{uuid: uuid} =
        building
        |> BuildingPayload.changeset()
        |> Repo.insert!()

      assert {:ok, _} =
               PayloadsProcessor.insert_development_from_building_payload(Multi.new(), uuid)

      assert Repo.one(JobQueue)
    end
  end

  describe "insert_images_from_image_payload/3" do
    test "create new images from image payload" do
      %{uuid: payload_uuid} =
        build(:images_payload)
        |> ImagePayload.changeset()
        |> Repo.insert!()

      Re.Factory.insert(:development, orulo_id: "999")

      assert [ok: inserted_image] =
               PayloadsProcessor.insert_images_from_image_payload(
                 Multi.new(),
                 payload_uuid,
                 "999"
               )

      assert inserted_image.filename == "qxo1cimsxmb2vnu5kcxw.jpg"
    end
  end
end
