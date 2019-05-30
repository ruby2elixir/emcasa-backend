defmodule ReIntegrations.Orulo.MapperTest do
  @moduledoc false

  use ReIntegrations.ModelCase

  alias ReIntegrations.{
    Orulo.Building,
    Orulo.Mapper
  }

  @building %Building{
    external_id: 999,
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
  }

  describe "building_payload_into_development_params" do
    test "parse building payload into development" do
      %{payload: %{"developer" => developer} = payload} = @building
      params = Mapper.building_payload_into_development_params(@building)

      assert params == %{
               name: Map.get(payload, "name"),
               description: Map.get(payload, "description"),
               builder: Map.get(developer, "name"),
               floor_count: Map.get(payload, "number_of_floors"),
               units_per_floor: Map.get(payload, "apts_per_floor"),
               phase: "building"
             }
    end
  end

  describe "building_payload_into_address_params" do
    test "parse building payload into address params" do
      %{payload: %{"address" => address}} = @building
      params = Mapper.building_payload_into_address_params(@building)

      assert params == %{
               street: Map.get(address, "street"),
               neighborhood: Map.get(address, "area"),
               city: Map.get(address, "city"),
               state: Map.get(address, "state"),
               postal_code: Map.get(address, "zip_code"),
               lat: Map.get(address, "latitude"),
               lng: Map.get(address, "longitude"),
               street_number: Map.get(address, "number") |> Integer.to_string()
             }
    end
  end
end
