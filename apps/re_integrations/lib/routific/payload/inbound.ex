defmodule ReIntegrations.Routific.Payload.Inbound do
  @moduledoc """
  Parses routific response.
  """
  @derive Jason.Encoder

  defstruct [:status, :solution, :unserved]

  @status_types ["finished", "pending", "error"]

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

  def build(_data), do: {:error, :invalid_input}

  defp build_solution(%{} = solution) do
    visits = build_visits_list(solution)

    if Enum.all?(visits, fn {_, visit} -> visit != :error end),
      do: {:ok, visits},
      else: {:error, :invalid_input}
  end

  defp build_solution(_solution), do: {:error, :invalid_input}

  defp build_visits_list(solution),
    do:
      Enum.reduce(solution, %{}, fn {calendar_uuid, visits}, acc ->
        Map.put(acc, calendar_uuid, Enum.map(visits, &build_visit/1))
      end)

  defp build_visit(%{"location_id" => location_id, "location_name" => address} = visit) do
    with {:ok, arrival} <- visit |> Map.get("arrival_time") |> to_time_struct(),
         {:ok, finish} <- visit |> Map.get("finish_time") |> to_time_struct() do
      %{
        id: location_id,
        address: address,
        start: arrival,
        end: finish
      }
    else
      _ -> :error
    end
  end

  defp build_visit(_visit), do: :error

  defp build_unserved(nil), do: {:ok, []}

  defp build_unserved(%{} = unserved), do: {:ok, unserved}

  defp build_unserved(_unserved), do: {:error, :invalid_input}

  defp to_time_struct(nil), do: {:ok, nil}

  defp to_time_struct(time_string), do: Time.from_iso8601("#{time_string}:00Z")
end
