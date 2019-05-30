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
        street_type: "Rua",
        street: "Cotoxó",
        number: 926,
        area: "Perdizes",
        city: "São Paulo",
        latitude: -23.5345,
        longitude: -46.6871,
        state: "SP",
        zip_code: "05021-001"
      }
    }
  }

  describe "building_payload_into_development_params" do
    @tag dev: true
    test "parse building payload into development" do
      %{payload: payload} = @building
      params = Mapper.building_payload_into_development_params(@building)

      assert params == %{
               name: Map.get(payload, :name),
               description: Map.get(payload, :description),
               builder: "EmCasa Incorporadora",
               floor_count: 8,
               units_per_floor: 2,
               phase: "building"
             }
    end
  end
end
