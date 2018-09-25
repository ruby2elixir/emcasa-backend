defmodule Re.CalendarsTest do
  use Re.ModelCase

  alias Re.Calendars

  describe "format_datetime/1" do
    test "should format datetime" do
      assert "Sábado, 29-9-2018 10:00 AM" == Calendars.format_datetime(~N[2018-09-29 10:00:00])

      assert "Domingo, 30-9-2018 3:00 PM" == Calendars.format_datetime(~N[2018-09-30 15:00:00])
    end
  end
end
