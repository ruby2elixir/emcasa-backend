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
    Calendars,
    Calendars.Calendar
  }

  @token Application.get_env(:re_integrations, :goth_token, Goth.Token)
  @timezone Application.get_env(:re_integrations, :google_calendar_timezone, "Ect/UTC")
  @default_acl Application.get_env(:re_integrations, :google_calendar_acl)

  @default_event_opts [timeZone: @timezone]

  defp conn do
    {:ok, token} = @token.for_scope("https://www.googleapis.com/auth/calendar")
    Connection.new(token.token)
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
    |> Keyword.merge(opts)
    |> Keyword.update(:start, nil, &to_event_date_time/1)
    |> Keyword.update(:end, nil, &to_event_date_time/1)
    |> (&struct(%Model.Event{}, &1)).()
  end

  defp to_event_date_time(%DateTime{} = date_time),
    do: %Model.EventDateTime{dateTime: date_time, timeZone: @timezone}

  def insert(params \\ %{}, calendar_opts \\ []) do
    with {:ok, calendar} <- insert_calendar(calendar_opts),
         {:ok, _acl} <- insert_acl(calendar) do
      params
      |> Map.put(:external_id, calendar.id)
      |> Calendars.insert()
    end
  end

  defp insert_calendar(calendar_opts),
    do:
      Api.Calendars.calendar_calendars_insert(conn(),
        body: struct(%Model.Calendar{}, calendar_opts)
      )

  defp insert_acl(calendar),
    do: Api.Acl.calendar_acl_insert(conn(), calendar.id, body: @default_acl)
end
