defmodule ReIntegrations.Routific.Payload.Outbound do
  @moduledoc """
  Builds routific payload.
  """
  @derive Jason.Encoder

  alias ReIntegrations.Routific

  defstruct [:visits, :fleet]

  defmodule InvalidInputError do
    defexception [:message]
  end

  def build(input) do
    with {:ok, visits} <- build_visits(input),
         {:ok, fleet} <- build_fleet(input) do
      {:ok, %__MODULE__{visits: visits, fleet: fleet}}
    end
  end

  defp build_visits(input) do
    try do
      {:ok,
       Enum.reduce(input, %{}, fn visit, acc ->
         unless Map.has_key?(visit, :id),
           do: raise(InvalidInputError, message: "visit id is required")

         Map.put(acc, visit.id, build_visit(visit))
       end)}
    rescue
      e in InvalidInputError -> {:error, e.message}
    end
  end

  defp build_visit(%{duration: duration, address: address, lat: lat, lng: lng} = visit) do
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

  defp build_visit(_visit), do: raise(InvalidInputError, message: "invalid visit input")

  defp build_fleet(_visits) do
    # TODO build fleet from photographers' google calendars
    {:ok, %{}}
  end

  defp to_time_string(%Time{} = time), do: Time.to_string(time) |> String.slice(0..4)

  defp to_time_string(time), do: time
end
