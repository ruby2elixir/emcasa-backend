defmodule ReIntegrations.Orulo.TypologyMapper do
  @moduledoc """
  Module to map orulo's typology into units.
  """

  @typology_attributes ~w(bedrooms bathrooms suites parking)
  @unit_attributes ~w(price private_area reference)

  def typology_payload_into_unit_params(typology, unit) do
    typology
    |> fetch_attributes(unit)
    |> Enum.reduce(%{}, &convert_typology_attribute(&1, &2))
  end

  defp fetch_attributes(typology, unit) do
    typology_attributes = Map.take(typology, @typology_attributes)
    unit_attributes = Map.take(unit, @unit_attributes)

    Map.merge(typology_attributes, unit_attributes)
  end

  defp convert_typology_attribute({"price", price}, acc) do
    Map.put(acc, :price, round(price))
  end

  defp convert_typology_attribute({"private_area", area}, acc) do
    Map.put(acc, :area, round(area))
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

  defp convert_typology_attribute({"reference", complement}, acc) do
    Map.put(acc, :complement, complement)
  end

  defp convert_typology_attribute(_, acc), do: acc
end
