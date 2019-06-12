defmodule ReIntegrations.Orulo.TypologyMapper do
  @moduledoc """
  Module to map orulo's typology into units.
  """
  alias ReIntegrations.Orulo.TypologyPayload

  @typology_attributes ~w(discount_price private_area bedrooms bathrooms suites parking)

  def typology_payload_into_unit_params(typology) do
    typology
    |> Map.take(@typology_attributes)
    |> Enum.reduce(%{}, &convert_typology_attribute(&1, &2))
  end

  defp convert_typology_attribute({"discount_price", price}, acc) do
    Map.put(acc, :price, price)
  end

  defp convert_typology_attribute({"private_area", area}, acc) do
    Map.put(acc, :area, area)
  end

  defp convert_typology_attribute({"bedrooms", rooms}, acc) do
    Map.put(acc, :rooms, rooms)
  end

  defp convert_typology_attribute({"bathrooms", bathrooms}, acc) do
    Map.put(acc, :bathrooms, bathrooms)
  end

  defp convert_typology_attribute({"parking", garage_spots}, acc) do
    Map.put(acc, :garage_spots, garage_spots)
  end

  defp convert_typology_attribute({"suites", suites}, acc) do
    Map.put(acc, :suites, suites)
  end

  defp convert_typology_attribute(_, acc), do: acc
end
