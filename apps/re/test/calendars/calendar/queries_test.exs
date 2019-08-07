defmodule Re.Calendars.Calendar.QueriesTest do
  use Re.ModelCase

  alias Re.{
    Calendars.Calendar.Queries,
    Repo
  }

  import Re.{
    CustomAssertion,
    Factory
  }

  defp map_uuid(list), do: Enum.map(list, &Map.get(&1, :uuid))

  describe "by_district_names/1" do
    test "should get all calendars by districts name" do
      district1 = insert(:district)
      district2 = insert(:district)
      insert(:calendar, districts: [district1])

      inserted_calendars = [
        insert(:calendar, districts: [district2]),
        insert(:calendar, districts: [district1, district2])
      ]

      selected_calendars =
        [district2.name]
        |> Queries.by_district_names()
        |> Repo.all()

      assert assert_mapper_match(inserted_calendars, selected_calendars, &map_uuid/1)
    end
  end
end
