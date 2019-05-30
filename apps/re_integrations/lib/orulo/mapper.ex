defmodule ReIntegrations.Orulo.Mapper do
  @moduledoc """
  Module to map external structures into persistable internal structures.
  """
  alias ReIntegrations.{
    Orulo.Building
  }

  def building_payload_into_development_params(%Building{} = %{payload: payload}) do
    Enum.reduce(payload, %{}, &convert_attribute(&1, &2))
  end

  defp convert_attribute({:name, name}, acc), do: Map.put(acc, :name, name)

  defp convert_attribute({:description, description}, acc),
    do: Map.put(acc, :description, description)

  defp convert_attribute({:developer, %{name: name}}, acc) do
    Map.put(acc, :builder, name)
  end

  defp convert_attribute({:number_of_floors, floor_count}, acc) do
    Map.put(acc, :floor_count, floor_count)
  end

  defp convert_attribute({:apts_per_floor, units_per_floor}, acc) do
    Map.put(acc, :units_per_floor, units_per_floor)
  end

  @phase_map %{
    "Em construção" => "building",
    "Pronto novo" => "delivered",
    "Pronto usado" => "delivered"
  }
  defp convert_attribute({:status, status}, acc) do
    phase = Map.get(@phase_map, status)
    Map.put(acc, :phase, phase)
  end

  defp convert_attribute(_, acc), do: acc
end
