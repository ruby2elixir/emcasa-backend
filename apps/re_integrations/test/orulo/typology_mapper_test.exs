defmodule ReIntegrations.Orulo.TypologyMapperTest do
  @moduledoc false

  use ReIntegrations.ModelCase

  alias ReIntegrations.Orulo.TypologyMapper

  describe "typology_into_units_params" do
    test "parse typology payload into units" do
      typology = %{
        "id" => "9544",
        "type" => "Apartamento",
        "bedrooms" => 3,
        "bathrooms" => 2,
        "suites" => 1,
        "parking" => 2
      }

      unit = %{
        "reference" => "51",
        "price" => 1_000_000.0,
        "private_area" => 84.0
      }

      params = TypologyMapper.typology_payload_into_unit_params(typology, unit)

      assert params == %{
               price: unit |> Map.get("price") |> round(),
               area: unit |> Map.get("private_area") |> round(),
               rooms: Map.get(typology, "bedrooms"),
               bathrooms: Map.get(typology, "bathrooms"),
               suites: Map.get(typology, "suites"),
               garage_spots: Map.get(typology, "parking"),
               complement: Map.get(unit, "reference")
             }
    end
  end
end
