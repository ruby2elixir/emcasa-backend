defmodule ReIntegrations.Salesforce.ZapierClient do
  @moduledoc """
  Client to send reports to Slack through Zapier.
  """

  alias Re.{
    Calendars
  }

  alias ReIntegrations.Routific

  @url Application.get_env(:re_integrations, :zapier_schedule_visits_url, "")
  @salesforce_opportunity_url Application.get_env(:re_integrations, :salesforce_opportunity_url)
  @http_client Application.get_env(:re_integrations, :http, HTTPoison)

  def report(%Routific.Payload.Inbound{} = payload) do
    with {:ok, date} <- payload.options |> Map.fetch!("date") |> Timex.parse("{ISO:Extended}") do
      post(%{
        body:
          "Visitas agendadas para #{format_date(date)}:\n" <>
            build_solution(payload) <>
            if(Enum.empty?(payload.unserved),
              do: "",
              else: "\n\nOpotunidades não agendadas:\n" <> build_unserved(payload)
            )
      })
    end
  end

  defp opportunity_url(id), do: "#{@salesforce_opportunity_url}/#{id}/view"

  defp format_date(date), do: Timex.format!(date, "{0D}/{0M}")

  defp format_visit_time(time, %{idle_time: idle_time}),
    do: time |> Time.add(idle_time * 60, :second) |> Calendars.format_time()

  defp build_unserved(%{unserved: unserved}),
    do:
      Enum.map(unserved, fn {id, reason} ->
        "[<#{opportunity_url(id)}\">|#{id}>] #{reason}"
      end)
      |> Enum.join("\n")

  defp build_solution(%{solution: solution}),
    do: Enum.map(solution, &build_route/1) |> Enum.join("\n")

  defp build_route({calendar_uuid, [_depot | visits]}),
    do:
      with(
        {:ok, calendar} <- Calendars.get(calendar_uuid),
        do:
          "*#{calendar.name}*:\n" <>
            (visits
             |> Enum.reject(&Map.get(&1, :break))
             |> Enum.map(fn visit ->
               "• [<#{opportunity_url(visit.id)}|#{visit.id}>] " <>
                 "#{format_visit_time(visit.start, visit)} - " <>
                 "#{format_visit_time(visit.end, visit)} | " <>
                 "#{visit.address}"
             end)
             |> Enum.join("\n"))
      )

  defp post(body),
    do: @url |> URI.parse() |> @http_client.post(Jason.encode!(body), [])
end
