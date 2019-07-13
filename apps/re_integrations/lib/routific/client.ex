defmodule ReIntegrations.Routific.Client do
  @moduledoc """
  Client to handle vehicle routing through routific.
  """

  alias ReIntegrations.Routific

  @api_key Application.get_env(:re_integrations, :routific_api_key, "")
  @api_url Application.get_env(:re_integrations, :routific_url, "https://api.routific.com")
  @http_client Application.get_env(:re_integrations, :http, HTTPoison)

  @api_headers [{"Authorization", "Bearer #{@api_key}"}, {"Content-Type", "application/json"}]

  def start_job(visits) do
    visits
    |> build_payload
    |> post("v1/vrp-long")
  end

  def fetch_job(job_id), do: get("jobs/" + job_id)

  def build_payload(visits) do
    %{
      "visits" => build_visits_payload(visits),
      "fleet" => get_fleet(visits)
    }
  end

  defp build_visits_payload(visits) do
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

  defp get_fleet(visits) do
    %{
      "eyy" => %{
        "start_location" => get_depot(visits),
        "shift_start" => "8:00",
        "end_start" => "18:00"
      }
    }
    |> Poison.encode!()
  end

  defp get_depot(visits) do
    [lat, lng] =
      visits
      |> lat_lng_list
      |> Geocalc.geographic_center()

    %{
      "id" => "depot",
      "name" => "depot",
      "lat" => lat,
      "lng" => lng
    }
  end

  defp lat_lng_list(visits),
    do: Enum.map(visits, fn %{"lat" => lat, "lng" => lng} -> [lat, lng] end)

  defp post(body, path) when is_map(body),
    do: @http_client.post(@api_url + path, Poison.encode!(body), @api_headers)

  defp get(path),
    do: @http_client.get(@api_url + path, @api_headers, [])
end
