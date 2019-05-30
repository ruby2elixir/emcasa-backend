defmodule ReIntegrations.OruloTest do
  @moduledoc false

  use ReIntegrations.ModelCase

  alias ReIntegrations.{
    Orulo,
    Orulo.Building,
    Orulo.JobQueue,
    Repo
  }

  alias Ecto.Multi

  describe "get_building_payload/2" do
    test "create o new job with to sync development" do
      assert {:ok, _} = Orulo.get_building_payload(100)
      assert Repo.one(JobQueue)
    end
  end

  describe "multi_building_insert/2" do
    test "create new building" do
      params = %{external_id: 666, payload: %{test: "building_payload"}}

      assert {:ok, %{building: inserted_building}} =
               Orulo.multi_building_insert(Multi.new(), params)

      assert inserted_building.uuid
      assert inserted_building.external_id == 666
      assert inserted_building.payload == %{test: "building_payload"}
    end

    test "enqueue a new parse job" do
      params = %{external_id: 666, payload: %{test: "building_payload"}}
      assert {:ok, _} = Orulo.multi_building_insert(Multi.new(), params)
      assert Repo.one(JobQueue)
    end
  end

  @building %Building{
    external_id: 999,
    payload: %{
      id: "999",
      name: "EmCasa 01",
      description:
        "Com 3 dormitórios e espaços amplos, o apartamento foi desenhado de uma forma que permite ventilação e iluminação natural e generosas em praticamente todos os seus ambientes – e funciona quase como uma casa solta no ar. Na melhor localização de Perdizes: com ótimas escolas, restaurantes e lojinhas simpáticas no entorno.",
      floor_area: 0.0,
      apts_per_floor: 2,
      number_of_floors: 8,
      status: "Em construção",
      webpage: "http://www.emcasa.com/",
      developer: %{
        id: "799",
        name: "EmCasa Incorporadora"
      },
      address: %{
        street_type: "Avenida",
        street: "Copacabana",
        number: 926,
        area: "Copacabana",
        city: "Rio de Janeiro",
        latitude: -23.5345,
        longitude: -46.6871,
        state: "RJ",
        zip_code: "05021-001"
      }
    }
  }

  describe "insert_development_from_building/1" do
    test "create new address from building" do
      %{uuid: uuid} =
        @building
        |> Building.changeset()
        |> Repo.insert!()

      Orulo.insert_development_from_building(uuid)
      assert new_address = Re.Repo.one(Re.Address)
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
      %{payload: payload = %{developer: developer}} = @building

      %{uuid: uuid} =
        @building
        |> Building.changeset()
        |> Repo.insert!()

      assert {:ok, development} = Orulo.insert_development_from_building(uuid)
      assert development.name == Map.get(payload, :name)
      assert development.description == Map.get(payload, :description)
      assert development.phase == "building"
      assert development.floor_count == Map.get(payload, :number_of_floors)
      assert development.units_per_floor == Map.get(payload, :apts_per_floor)

      assert development.builder == Map.get(developer, :name)
    end
  end
end
