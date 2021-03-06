defmodule ReIntegrations.Google.CalendarsTest do
  @moduledoc false

  use ReIntegrations.ModelCase

  alias GoogleApi.Calendar.V3.Model

  alias ReIntegrations.Google.Calendars

  import Tesla.Mock

  import Re.Factory

  @calendar_id "calendar123"

  @calendar_response """
  {
    "id": "#{@calendar_id}",
    "kind": "calendar#calendar"
  }
  """

  @acl_response """
  {
    "kind": "calendar#acl"
  }
  """

  @event_response """
  {
    "kind": "calendar#event"
  }
  """

  describe "insert/2" do
    setup do
      mock(fn
        %{method: :post, url: "https://www.googleapis.com/calendar/v3/calendars"} ->
          %Tesla.Env{status: 200, body: @calendar_response}

        %{
          method: :post,
          url: "https://www.googleapis.com/calendar/v3/calendars/#{@calendar_id}/acl"
        } ->
          %Tesla.Env{status: 200, body: @acl_response}
      end)

      :ok
    end

    test "creates a google calendar and inserts it to the database" do
      address = insert(:address)

      assert {:ok, calendar = %Re.Calendars.Calendar{}} =
               Calendars.insert(%{
                 name: "test",
                 speed: "slow",
                 shift_start: ~T[10:00:00],
                 shift_end: ~T[12:00:00],
                 address_uuid: address.uuid
               })

      assert ~T[10:00:00] == calendar.shift_start
      assert ~T[12:00:00] == calendar.shift_end
      assert address.uuid == calendar.address_uuid
    end
  end

  describe "insert_event/2" do
    setup do
      mock(fn
        %{
          method: :post,
          url: "https://www.googleapis.com/calendar/v3/calendars/#{@calendar_id}/events"
        } ->
          %Tesla.Env{status: 200, body: @event_response}
      end)

      :ok
    end

    test "inserts an event into a google calendar" do
      calendar = insert(:calendar, external_id: @calendar_id)
      {:ok, start_time} = DateTime.now("Etc/UTC")

      assert {:ok, %Model.Event{}} =
               Calendars.insert_event(calendar, summary: "test", start: start_time)
    end
  end
end
