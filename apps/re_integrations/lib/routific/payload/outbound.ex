defmodule ReIntegrations.Routific.Payload.Outbound do
  @moduledoc """
  Builds routific outbound payload.
  """

  alias ReIntegrations.Routific

  defstruct [:visits, :fleet]

  def build(visits) do
    %__MODULE__{
      visits: build_visits(visits),
      fleet: build_fleet(visits)
    }
  end

  defp build_visits(visits) do
    Enum.reduce(visits, %{}, fn visit, acc ->
      visit
      |> Map.take(["duration", "start", "end"])
      |> Map.put_new("start", Routific.shift_start())
      |> Map.put_new("end", Routific.shift_end())
      |> Map.put("location", %{
        "name" => visit["address"],
        "lat" => visit["lat"],
        "lng" => visit["lng"]
      })
      |> (&Map.put(acc, visit["id"], &1)).()
    end)
  end

  defp build_fleet(_visits) do
    # TODO build fleet from photographers' google calendars
    %{}
  end
end
