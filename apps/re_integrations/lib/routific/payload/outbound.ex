defmodule ReIntegrations.Routific.Payload.Outbound do
  @moduledoc """
  Builds routific payload.
  """
  @derive Jason.Encoder

  alias Re.Calendars.Calendar
  alias ReIntegrations.Routific

  defstruct [:visits, :fleet, :options]

  def build(input, opts) do
    with {:ok, visits} <- build_visits(input),
         {:ok, fleet} <- build_fleet() do
      {:ok, %__MODULE__{visits: visits, fleet: fleet, options: build_options(opts)}}
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

  defp build_visit(%{duration: _duration, address: address} = visit) do
    visit
    |> Map.take([:duration, :start, :end, :notes, :type])
    |> Map.update(:start, Routific.shift_start(), &to_time_string/1)
    |> Map.update(:end, Routific.shift_end(), &to_time_string/1)
    |> Map.put(:customNotes, Map.get(visit, :custom_notes, %{}))
    |> Map.put(:location, %{
      name: address,
      address: address
    })
  end

  defp build_visit(_visit), do: :error

  defp build_fleet do
    case get_calendars() do
      calendars when length(calendars) !== 0 ->
        {:ok,
         Enum.reduce(calendars, %{}, fn calendar, acc ->
           Map.put(acc, calendar.uuid, %{
             speed: calendar.speed,
             start_location: build_depot(calendar),
             shift_start: to_time_string(calendar.shift_start),
             shift_end: to_time_string(calendar.shift_end),
             type: calendar.types,
             breaks: get_breaks()
           })
         end)}

      _ ->
        {:error, :no_calendars_found}
    end
  end

  defp get_calendars do
    Calendar
    |> Calendar.Queries.preload_relations([:address])
    |> Re.Repo.all()
  end

  defp build_depot(%{address: address}),
    do: %{
      id: address.id,
      name: "#{address.street}, #{address.street_number}",
      lat: address.lat,
      lng: address.lng
    }

  defp get_breaks, do: [%{id: "lunch", start: "12:00", end: "13:00"}]

  defp build_options(options), do: Enum.into(options, %{})

  defp to_time_string(%Time{} = time), do: time |> Time.to_string() |> String.slice(0..4)

  defp to_time_string(time), do: time
end
