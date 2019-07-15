defmodule Re.GoogleCalendars.Calendar.QueriesTest do
  use Re.ModelCase

  alias Re.{
    GoogleCalendars.Calendar.Queries,
    Repo
  }

  import Re.Factory

  describe "by_districts/1" do
    test "should get all calendars by districts name" do
      district1 = insert(:district)
      district2 = insert(:district)
      insert(:calendar, districts: [district1])

      calendars =
        Enum.sort([
          insert(:calendar, districts: [district2]),
          insert(:calendar, districts: [district1, district2])
        ])

      assert calendars ==
               Queries.by_districts([district2.name])
               |> Queries.preload_relations()
               |> Repo.all()
               |> Enum.sort()
    end
  end
end
