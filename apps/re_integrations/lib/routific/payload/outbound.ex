defmodule ReIntegrations.Routific.Payload.Outbound do
  @moduledoc """
  Builds routific payload.
  """
  @derive Jason.Encoder

  alias ReIntegrations.Routific

  defstruct [:visits, :fleet]

  def build(input) do
    with {:ok, visits} <- build_visits(input),
         {:ok, fleet} <- build_fleet(input) do
      {:ok, %__MODULE__{visits: visits, fleet: fleet}}
    end
  end

  defp build_visits(input) do
    visits = build_visits_list(input)

    if visits != :error and Enum.all?(visits, fn {_, visit} -> visit != :error end),
      do: {:ok, visits},
      else: {:error, :invalid_input}
  end

  defp build_visits_list(input),
    do:
      Enum.reduce(input, %{}, fn visit, acc ->
        if is_map(acc) and Map.has_key?(visit, :id),
          do: Map.put(acc, visit.id, build_visit(visit)),
          else: :error
      end)

  defp build_visit(%{duration: _duration, address: address, lat: lat, lng: lng} = visit) do
    visit
    |> Map.take([:duration, :start, :end])
    |> Map.update(:start, Routific.shift_start(), &to_time_string/1)
    |> Map.update(:end, Routific.shift_end(), &to_time_string/1)
    |> Map.put(:location, %{
      name: address,
      lat: lat,
      lng: lng
    })
  end

  defp build_visit(_visit), do: :error

  defp build_fleet(_visits) do
    # TODO build fleet from photographers' google calendars
    {:ok, %{}}
  end

  defp to_time_string(%Time{} = time), do: time |> Time.to_string() |> String.slice(0..4)

  defp to_time_string(time), do: time
end
