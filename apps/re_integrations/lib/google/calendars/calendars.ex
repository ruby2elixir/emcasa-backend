defmodule ReIntegrations.Google.Calendars do
  @moduledoc """
  Module for handling requests on google calendars throught google's api
  """
  alias GoogleApi.Calendar.V3.{
    Api,
    Connection,
    Model
  }

  alias Re.{
    GoogleCalendars,
    GoogleCalendars.Calendar
  }

  @timezone Application.get_env(:re_integrations, :google_api_timezone, "America/Sao_Paulo")
  @default_event_opts [timeZone: @timezone]

  defp conn do
    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/calendar")
    Connection.new(token.token)
  end

  def get_events(%Calendar{} = calendar, opts \\ []) do
    Api.Events.calendar_events_list(conn(), calendar.external_id, opts)
  end

  def insert_event(%Calendar{} = calendar, event_opts \\ []) do
    Api.Events.calendar_events_insert(
      conn(),
      calendar.external_id,
      body: build_event(event_opts)
    )
  end

  defp build_event(opts) do
    @default_event_opts
    |> Map.merge(opts)
    |> Keyword.update(:start, nil, &to_event_date_time/1)
    |> Keyword.update(:end, nil, &to_event_date_time/1)
    |> (&struct(%Model.Event{}, &1)).()
  end

  defp to_event_date_time(%DateTime{} = date_time),
    do: %Model.EventDateTime{dateTime: date_time, timeZone: @timezone}

  defp to_event_date_time(date_time), do: date_time

  def insert(params \\ %{}, calendar_opts \\ []) do
    with {:ok, calendar} <-
           Api.Calendars.calendar_calendars_insert(conn(),
             body: struct(%Model.Calendar{}, calendar_opts)
           ) do
      params
      |> Map.put(:external_id, calendar.id)
      |> GoogleCalendars.insert()
    end
  end
end
