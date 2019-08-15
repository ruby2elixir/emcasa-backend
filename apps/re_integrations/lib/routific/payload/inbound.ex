defmodule ReIntegrations.Routific.Payload.Inbound do
  @moduledoc """
  Parses routific response.
  """
  @derive Jason.Encoder

  defstruct [:status, :solution, :unserved, :options]

  @status_types ["finished", "pending", "error"]

  def build(%{"status" => "finished", "output" => output, "input" => input}) do
    with {:ok, solution} <- build_solution(output["solution"], input),
         {:ok, unserved} <- build_unserved(output["unserved"]) do
      {:ok,
       %__MODULE__{
         status: :finished,
         solution: solution,
         unserved: unserved,
         options: input["options"]
       }}
    end
  end

  def build(%{"status" => status}) when status in @status_types,
    do: {:ok, %__MODULE__{status: String.to_atom(status)}}

  def build(_data), do: {:error, :invalid_input}

  defp build_solution(%{} = solution, %{"visits" => visits_input}) do
    visits = build_visits_list(solution, visits_input)

    if Enum.all?(visits, fn {_, visit} -> visit != :error end),
      do: {:ok, visits},
      else: {:error, :invalid_input}
  end

  defp build_solution(_solution, _input), do: {:error, :invalid_input}

  defp build_visits_list(solution, input),
    do:
      Enum.reduce(solution, %{}, fn {calendar_uuid, visits}, acc ->
        Map.put(acc, calendar_uuid, Enum.map(visits, &build_visit(&1, input)))
      end)

  defp build_visit(%{"location_id" => location_id} = visit, input) do
    with {:ok, arrival} <- visit |> Map.get("arrival_time") |> to_time_struct(),
         {:ok, finish} <- visit |> Map.get("finish_time") |> to_time_struct() do
      %{
        id: location_id,
        start: arrival,
        end: finish,
        address: Map.get(visit, "location_name"),
        break: Map.get(visit, "break", false),
        idle_time: Map.get(visit, "idle_time", 0),
        notes: get_in(input, [location_id, "notes"]),
        custom_notes: get_in(input, [location_id, "customNotes"])
      }
    else
      _ -> :error
    end
  end

  defp build_visit(_visit, _input), do: :error

  defp build_unserved(nil), do: {:ok, []}

  defp build_unserved(%{} = unserved), do: {:ok, unserved}

  defp build_unserved(_unserved), do: {:error, :invalid_input}

  defp to_time_struct(nil), do: {:ok, nil}

  defp to_time_struct(time_string), do: Time.from_iso8601("#{time_string}:00Z")
end
