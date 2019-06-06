defmodule ReIntegrations.Factory do
  @moduledoc """
  Use the factories here in tests.
  """

  use ExMachina.Ecto, repo: ReIntegrations.Repo

  def building_factory do
    %ReIntegrations.Orulo.BuildingPayload{
      uuid: UUID.uuid4(),
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
        },
        "features" => [
          "Fitness",
          "Fitness ao ar livre",
          "Invalid Feature",
          "Porteiro eletrônico"
        ]
      }
    }
  end

  def images_payload_factory do
    %ReIntegrations.Orulo.ImagePayload{
      external_id: 999,
      payload: %{
        "images" => [
          %{
            "id" => "100",
            "description" => "Fachada",
            "1024x1024" =>
              "https://s3.amazonaws.com/uploaded.prod.corretordireto/images/properties/large/180227.jpg?1557215818"
          },
          %{
            "id" => "101",
            "description" => "Hall",
            "1024x1024" =>
              "https://s3.amazonaws.com/uploaded.prod.corretordireto/images/properties/large/180221.jpg?1557215921"
          }
        ]
      }
    }
  end
end
