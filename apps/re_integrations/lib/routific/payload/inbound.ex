defmodule ReIntegrations.Routific.Payload.Inbound do
  @moduledoc """
  Parses routific response.
  """
  @derive Jason.Encoder

  defstruct [:status, :solution, :unserved]

  @status_types ["finished", "pending", "error"]

  defmodule InvalidInputError do
    defexception [:message]
  end

  def build(%{"status" => "finished", "output" => output}) do
    with {:ok, solution} <- build_solution(output["solution"]),
         {:ok, unserved} <- build_unserved(output["unserved"]) do
      {:ok,
       %__MODULE__{
         status: :finished,
         solution: solution,
         unserved: unserved
       }}
    end
  end

  def build(%{"status" => status}) when status in @status_types,
    do: {:ok, %__MODULE__{status: String.to_atom(status)}}

  def build(_data), do: {:error, "invalid response"}

  defp build_solution(%{} = solution) do
    try do
      {:ok,
       Enum.reduce(solution, %{}, fn {calendar_uuid, visits}, acc ->
         Map.put(acc, calendar_uuid, Enum.map(visits, &build_visit/1))
       end)}
    rescue
      e in InvalidInputError -> {:error, e.message}
    end
  end

  defp build_solution(_solution), do: {:error, "invalid solution input"}

  defp build_visit(%{"location_id" => location_id, "location_name" => address} = visit) do
    %{
      id: location_id,
      address: address,
      start: Map.get(visit, "arrival_time"),
      end: Map.get(visit, "finish_time")
    }
  end

  defp build_visit(_visit), do: raise(InvalidInputError, message: "invalid visit input")

  defp build_unserved(nil), do: {:ok, []}

  defp build_unserved(%{} = unserved), do: {:ok, unserved}

  defp build_unserved(_unserved), do: {:error, "invalid unserved input"}
end
