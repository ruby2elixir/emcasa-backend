defmodule ReIntegrations.Routific.Payload.Inbound do
  @moduledoc """
  Handle routific outbound payload.
  """

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
    Enum.map(solution, fn {calendar_uuid, visits} ->
      {calendar_uuid, Enum.map(visits, &build_visit/1)}
    end)
  end

  defp build_visit(visit) do
    %{
      lead_id: visit["location_id"],
      address: visit["location_name"],
      start: Map.get(visit, "arrival_time"),
      end: Map.get(visit, "finish_time")
    }
  end

  defp build_unserved(nil), do: []

  defp build_unserved(unserved) do
    Enum.map(unserved, fn {lead_id, reason} -> {lead_id, reason} end)
  end
end
