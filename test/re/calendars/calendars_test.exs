defmodule Re.CalendarsTest do
  use Re.ModelCase

  alias Re.Calendars

  describe "format_datetime/1" do
    test "should format datetime" do
      assert "Sábado, 29-9-2018 10:00 AM" == Calendars.format_datetime(~N[2018-09-29 10:00:00])

      assert "Domingo, 30-9-2018 3:00 PM" == Calendars.format_datetime(~N[2018-09-30 15:00:00])
    end
  end

  describe "generate_tour_options/2" do
    test "should generate only one day option" do
      now = ~N[2018-09-29 10:00:00]

      assert [~N[2018-10-01 09:00:00], ~N[2018-10-01 17:00:00]] ==
               now |> Calendars.generate_tour_options(1) |> Enum.sort()
    end

    test "should error when option is invalid" do
      now = ~N[2018-09-29 10:00:00]

      assert {:error, :invalid_option} == Calendars.generate_tour_options(now, 0)
      assert {:error, :invalid_option} == Calendars.generate_tour_options(now, -1)
    end

    test "should generate multiple days options" do
      now = ~N[2018-09-22 10:00:00]

      assert [
               ~N[2018-09-24 09:00:00],
               ~N[2018-09-24 17:00:00],
               ~N[2018-09-25 09:00:00],
               ~N[2018-09-25 17:00:00],
               ~N[2018-09-26 09:00:00],
               ~N[2018-09-26 17:00:00],
               ~N[2018-09-27 09:00:00],
               ~N[2018-09-27 17:00:00]
             ] == now |> Calendars.generate_tour_options(4) |> Enum.sort()
    end
  end
end
