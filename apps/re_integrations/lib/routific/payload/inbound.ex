defmodule ReIntegrations.Routific.Payload.Inbound do
  @moduledoc """
  Parses routific response.
  """
  @derive Jason.Encoder

  defstruct [:status, :solution, :unserved]

  def build(%{"status" => "finished", "output" => output}) do
    %__MODULE__{
      status: "finished",
      solution: build_solution(output["solution"]),
      unserved: build_unserved(output["unserved"])
    }
  end

  def build(%{"status" => status}), do: %__MODULE__{status: status}

  defp build_solution(solution) do
    Enum.reduce(solution, %{}, fn {calendar_uuid, visits}, acc ->
      Map.put(acc, calendar_uuid, Enum.map(visits, &build_visit/1))
    end)
  end

  defp build_visit(%{"location_id" => location_id, "location_name" => address} = visit) do
    %{
      id: location_id,
      address: address,
      start: Map.get(visit, "arrival_time"),
      end: Map.get(visit, "finish_time")
    }
  end

  defp build_unserved(nil), do: []

  defp build_unserved(unserved), do: unserved
end
