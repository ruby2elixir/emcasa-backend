defmodule ReIntegrations.Orulo.PayloadProcessorTest do
  @moduledoc false

  use ReIntegrations.ModelCase

  alias ReIntegrations.{
    Orulo.BuildingPayload,
    Orulo.JobQueue,
    Orulo.PayloadProcessor,
    Repo
  }

  alias Ecto.Multi
  import ExUnit.CaptureLog

  import Re.CustomAssertion
  import ReIntegrations.Factory

  describe "insert_development_from_building_payload/1" do
    test "create new address from building" do
      %{uuid: uuid} =
        build(:building_payload)
        |> BuildingPayload.changeset()
        |> Repo.insert!()

      assert {:ok, %{insert_address: new_address}} =
               PayloadProcessor.insert_development_from_building_payload(Multi.new(), uuid)

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
      %{uuid: uuid, payload: payload = %{"developer" => developer}} = insert(:building_payload)

      assert {:ok, %{insert_development: development}} =
               PayloadProcessor.insert_development_from_building_payload(Multi.new(), uuid)

      assert development.uuid
      assert development.name == Map.get(payload, "name")
      assert development.description == Map.get(payload, "description")
      assert development.phase == "building"
      assert development.floor_count == Map.get(payload, "number_of_floors")
      assert development.units_per_floor == Map.get(payload, "apts_per_floor")

      assert development.builder == Map.get(developer, "name")
    end

    test "enqueue fetch images, fetch typologies and process tag jobs" do
      %{uuid: uuid} = insert(:building_payload)

      assert {:ok, _} =
               PayloadProcessor.insert_development_from_building_payload(Multi.new(), uuid)

      enqueued_jobs = Repo.all(JobQueue)

      assert_enqueued_job(enqueued_jobs, "fetch_images_from_orulo")
      assert_enqueued_job(enqueued_jobs, "process_orulo_tags")
      assert_enqueued_job(enqueued_jobs, "fetch_typologies")
    end
  end

  describe "insert_images_from_image_payload/3" do
    test "create new images from image payload" do
      %{uuid: payload_uuid} = insert(:images_payload)

      Re.Factory.insert(:development, orulo_id: "999")

      {:ok, %{insert_images: [ok: inserted_image]}} =
        PayloadProcessor.insert_images_from_image_payload(
          Multi.new(),
          payload_uuid
        )

      assert inserted_image.filename == "qxo1cimsxmb2vnu5kcxw.jpg"
    end
  end

  describe "process_typologies/2" do
    test "create new units from both typology and unit payloads merge" do
      insert(:typology_payload,
        payload: %{
          "typologies" => [
            %{
              "id" => "1",
              "type" => "Apartamento",
              "original_price" => 1_000_000.0,
              "discount_price" => 1_000_000.0,
              "private_area" => 100.0,
              "bedrooms" => 3,
              "bathrooms" => 2,
              "suites" => 1,
              "parking" => 2
            }
          ]
        }
      )

      %{uuid: payload_uuid} = insert(:units_payload, building_id: "999", typology_id: "1")

      Re.Factory.insert(:development, orulo_id: "999")

      {:ok,
       %{
         insert_units: [
           ok: %{add_unit: inserted_unit_1},
           ok: %{add_unit: inserted_unit_2}
         ]
       }} =
        PayloadProcessor.process_typologies(
          Multi.new(),
          payload_uuid
        )

      assert inserted_unit_1.uuid
      assert inserted_unit_1.price == 1_000_000
      assert inserted_unit_1.area == 100
      assert inserted_unit_1.rooms == 3
      assert inserted_unit_1.bathrooms == 2
      assert inserted_unit_1.suites == 1
      assert inserted_unit_1.garage_spots == 2
      assert inserted_unit_1.garage_type == "unknown"
      assert inserted_unit_1.complement == "50"
      assert inserted_unit_1.status == "active"

      assert inserted_unit_2.uuid
      assert inserted_unit_2.price == 2_000_000
      assert inserted_unit_2.area == 100
      assert inserted_unit_2.rooms == 3
      assert inserted_unit_2.bathrooms == 2
      assert inserted_unit_2.suites == 1
      assert inserted_unit_2.garage_spots == 2
      assert inserted_unit_2.garage_type == "unknown"
      assert inserted_unit_2.complement == "100"
      assert inserted_unit_1.status == "active"
    end

    @tag capture_log: true
    test "log errors when try to add an unit with invalid attributes" do
      insert(:typology_payload,
        payload: %{
          "typologies" => [
            %{
              "id" => "1",
              "type" => "Apartamento",
              "original_price" => 1_000_000.0,
              "discount_price" => 1_000_000.0,
              "private_area" => 100.0,
              "bedrooms" => 3,
              "bathrooms" => 2,
              "suites" => 1,
              "parking" => 2
            }
          ]
        }
      )

      %{uuid: payload_uuid} =
        insert(:units_payload,
          building_id: "999",
          typology_id: "1",
          payload: %{
            "units" => [
              %{
                "reference" => "50",
                "price" => 1_000.0,
                "private_area" => 10.0
              }
            ]
          }
        )

      Re.Factory.insert(:development, orulo_id: "999")

      assert capture_log(fn ->
               {:ok, _} =
                 PayloadProcessor.process_typologies(
                   Multi.new(),
                   payload_uuid
                 )
             end) =~
               "Failed to insert Orulo unit, reason"
    end
  end

  describe "process_orulo_tags/2" do
    test "create new tags from building payload" do
      Re.Factory.insert(:tag, name: "Academia", name_slug: "academia")
      Re.Factory.insert(:tag, name: "Portaria Eletrônica", name_slug: "portaria-eletronica")
      %{uuid: building_uuid} = insert(:building_payload)

      development = Re.Factory.insert(:development, orulo_id: "999")

      {:ok, %{insert_tags: _}} = PayloadProcessor.process_orulo_tags(Multi.new(), building_uuid)

      development = Re.Repo.preload(development, :tags)
      assert 2 == Enum.count(development.tags)
    end

    test "do not create new tags when there's no feature on payload" do
      %{uuid: building_uuid} =
        insert(:building_payload,
          payload: %{
            "id" => "999",
            "name" => "EmCasa 01",
            "description" =>
              "Com 3 dormitórios e espaços amplos, o apartamento foi desenhado de uma forma que permite ventilação e iluminação natural e generosas em praticamente todos os seus ambientes – e funciona quase como uma casa solta no ar. Na melhor localização de Perdizes: com ótimas escolas, restaurantes e lojinhas simpáticas no entorno.",
            "floor_area" => 0.0,
            "apts_per_floor" => 2,
            "number_of_floors" => 8,
            "status" => "Em construção",
            "webpage" => "http://www.emcasa.com/",
            "developer" => %{
              "id" => "799",
              "name" => "EmCasa Incorporadora"
            },
            "address" => %{
              "street_type" => "Avenida",
              "street" => "Copacabana",
              "number" => 926,
              "area" => "Copacabana",
              "city" => "Rio de Janeiro",
              "latitude" => -23.5345,
              "longitude" => -46.6871,
              "state" => "RJ",
              "zip_code" => "05021-001"
            }
          }
        )

      Re.Factory.insert(:tag, name: "Academia", name_slug: "academia")
      Re.Factory.insert(:tag, name: "Portaria Eletrônica", name_slug: "portaria-eletronica")

      development = Re.Factory.insert(:development, orulo_id: "999")

      {:ok, %{insert_tags: _}} = PayloadProcessor.process_orulo_tags(Multi.new(), building_uuid)

      development = Re.Repo.preload(development, :tags)
      assert Enum.empty?(development.tags)
    end
  end
end
