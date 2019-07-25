defmodule Re.GoogleCalendarsTest do
  use Re.ModelCase

  alias Re.{
    GoogleCalendars,
    GoogleCalendars.Calendar
  }

  import Re.Factory

  describe "get_preloaded/1" do
    test "should retrieve a calendar with preloaded relations" do
      calendar =
        insert(:calendar, address: insert(:address), districts: insert_list(2, :district))

      assert {:ok, retrieved_calendar} = GoogleCalendars.get_preloaded(calendar.uuid)
      assert retrieved_calendar.external_id == calendar.external_id
      assert retrieved_calendar.address == calendar.address
      assert retrieved_calendar.districts == calendar.districts
    end
  end

  describe "insert/1" do
    test "should insert a calendar" do
      address = insert(:address)

      assert {:ok, inserted_calendar} =
               GoogleCalendars.insert(%{
                 address: address,
                 external_id: "id"
               })

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
