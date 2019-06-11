defmodule ReIntegrations.Orulo.MapperTest do
  @moduledoc false

  use ReIntegrations.ModelCase

  alias ReIntegrations.{
    Orulo.Mapper
  }

  import ReIntegrations.Factory

  describe "building_payload_into_development_params" do
    test "parse building payload into development" do
      %{payload: %{"developer" => developer} = payload} = building = build(:building_payload)
      params = Mapper.building_payload_into_development_params(building)

      assert params == %{
               name: Map.get(payload, "name"),
               description: Map.get(payload, "description"),
               builder: Map.get(developer, "name"),
               floor_count: Map.get(payload, "number_of_floors"),
               units_per_floor: Map.get(payload, "apts_per_floor"),
               phase: "building",
               orulo_id: Map.get(payload, "id")
             }
    end
  end

  describe "building_payload_into_address_params" do
    test "parse building payload into address params" do
      %{payload: %{"address" => address}} = building = build(:building_payload)
      params = Mapper.building_payload_into_address_params(building)

      assert params == %{
               street: Map.get(address, "street"),
               neighborhood: Map.get(address, "area"),
               city: Map.get(address, "city"),
               state: Map.get(address, "state"),
               postal_code: Map.get(address, "zip_code"),
               lat: Map.get(address, "latitude"),
               lng: Map.get(address, "longitude"),
               street_number: address |> Map.get("number") |> Integer.to_string()
             }
    end
  end
end
