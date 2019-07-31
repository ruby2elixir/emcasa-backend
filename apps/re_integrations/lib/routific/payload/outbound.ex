defmodule ReIntegrations.Routific.Payload.Outbound do
  @moduledoc """
  Builds routific payload.
  """
  @derive Jason.Encoder

  alias Re.GoogleCalendars.Calendar
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

  defp build_fleet(visits) do
    visits
    |> get_neighborhoods()
    |> get_calendars()
    |> case do
      calendars when length(calendars) !== 0 ->
        {:ok,
         Enum.reduce(calendars, %{}, fn calendar, acc ->
           Map.put(acc, calendar.uuid, %{
             start_location: build_depot(calendar),
             shift_start: to_time_string(calendar.shift_start),
             shift_end: to_time_string(calendar.shift_end)
           })
         end)}

      _ ->
        {:error, :no_calendars_found}
    end
  end

  defp get_neighborhoods(visits) do
    visits
    |> Enum.map(&Map.get(&1, :neighborhood))
    |> Enum.uniq()
  end

  defp get_calendars(neighborhoods) do
    Calendar
    |> Calendar.Queries.by_district_names(neighborhoods)
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

  defp to_time_string(%Time{} = time), do: time |> Time.to_string() |> String.slice(0..4)

  defp to_time_string(time), do: time
end
