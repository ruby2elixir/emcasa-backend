defmodule ReIntegrations.Salesforce.Mapper.Zapier do
  @moduledoc """
  Module for buillding zapier messages from a routific payload.
  """

  alias Re.Calendars

  alias ReIntegrations.Routific

  @salesforce_opportunity_url Application.get_env(:re_integrations, :salesforce_opportunity_url)

  def build_report(%Routific.Payload.Inbound{} = payload) do
    with {:ok, date} <- payload.options |> Map.fetch!("date") |> Timex.parse("{ISO:Extended}") do
      {:ok, %{body: build_body(payload, date)}}
    end
  end

  defp build_body(payload, date) do
    [
      if(not Enum.empty?(payload.solution),
        do:
          "Sessões de tour agendadas para #{format_date(date)}:\n" <>
            build_solution(payload)
      ),
      if(not Enum.empty?(payload.unserved),
        do: "Opotunidades não agendadas:\n" <> build_unserved(payload)
      )
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n\n")
    |> case do
      "" -> "Nenhuma sessão agendada para #{format_date(date)}."
      body -> body
    end
  end

  defp opportunity_url(id), do: "#{@salesforce_opportunity_url}/#{id}/view"

  defp format_date(date), do: Timex.format!(date, "{0D}/{0M}")

  defp format_visit_time(time, %{idle_time: idle_time}),
    do: time |> Time.add(idle_time * 60, :second) |> Calendars.format_time()

  defp build_unserved(%{unserved: unserved}),
    do:
      unserved
      |> Enum.map(fn {id, reason} ->
        "[<#{opportunity_url(id)}\">|#{id}>] #{reason}"
      end)
      |> Enum.join("\n")

  defp build_solution(%{solution: solution}),
    do: solution |> Enum.map(&build_route/1) |> Enum.join("\n")

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
end
