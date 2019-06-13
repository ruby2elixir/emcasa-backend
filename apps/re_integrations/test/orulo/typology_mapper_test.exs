defmodule ReIntegrations.Orulo.TypologyMapperTest do
  @moduledoc false

  use ReIntegrations.ModelCase

  alias ReIntegrations.Orulo.TypologyMapper

  import ReIntegrations.Factory

  describe "typology_into_units_params" do
    test "parse typology payload into units" do
      %{payload: %{"typologies" => [typology, _]}} = build(:typology_payload)
      params = TypologyMapper.typology_payload_into_unit_params(typology)

      assert params == %{
               price: Map.get(typology, "discount_price") |> round(),
               area: Map.get(typology, "private_area") |> round(),
               rooms: Map.get(typology, "bedrooms"),
               bathrooms: Map.get(typology, "bathrooms"),
               suites: Map.get(typology, "suites"),
               garage_spots: Map.get(typology, "parking")
             }
    end
  end
end
