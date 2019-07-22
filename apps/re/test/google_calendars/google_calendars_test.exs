defmodule Re.GoogleCalendarsTest do
  use Re.ModelCase

  alias Re.{
    GoogleCalendars,
    GoogleCalendars.Calendar
  }

  import Re.Factory

  describe "insert/1" do
    @calendar_params %{external_id: "id"}

    test "should insert a calendar" do
      assert {:ok, inserted_calendar} = GoogleCalendars.insert(@calendar_params)

      assert retrieved_calendar = Repo.get(Calendar, inserted_calendar.uuid)
      assert retrieved_calendar.external_id == inserted_calendar.external_id
    end
  end

  describe "upsert_districts/2" do
    test "should insert districts to a calendar" do
      districts = insert_list(2, :district)
      calendar = insert(:calendar)

      assert {:ok, retrieved_calendar} = GoogleCalendars.upsert_districts(calendar, districts)
      assert districts == retrieved_calendar.districts
    end
  end
end
