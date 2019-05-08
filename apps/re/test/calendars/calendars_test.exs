defmodule Re.CalendarsTest do
  use Re.ModelCase

  alias Re.{
    Calendars,
    Calendars.TourAppointment,
    PubSub
  }

  import Re.Factory

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
             ] == Calendars.generate_tour_options(now, 4)
    end
  end

  describe "schedule_tour/1" do
    test "should schedule tour appointment" do
      PubSub.subscribe("tour_appointment")
      %{uuid: listing_uuid} = insert(:listing)
      %{uuid: site_seller_lead_uuid} = insert(:site_seller_lead)

      params = %{
        options: [
          %{datetime: ~N[2018-01-01 10:00:00.000Z]}
        ],
        wants_pictures: true,
        wants_tour: true,
        listing_uuid: listing_uuid,
        site_seller_lead_uuid: site_seller_lead_uuid
      }

      {:ok, _} = Calendars.schedule_tour(params)

      assert tour_appointment = Repo.one(TourAppointment)
      assert listing_uuid == tour_appointment.listing_uuid
      assert site_seller_lead_uuid == tour_appointment.site_seller_lead_uuid
      assert ~N[2018-01-01 10:00:00] = tour_appointment.option

      assert_receive %{new: _, topic: "tour_appointment", type: :new}
    end

    test "should schedule tour appointment without option" do
      PubSub.subscribe("tour_appointment")
      %{uuid: listing_uuid} = insert(:listing)
      %{uuid: site_seller_lead_uuid} = insert(:site_seller_lead)

      params = %{
        wants_pictures: true,
        wants_tour: true,
        listing_uuid: listing_uuid,
        site_seller_lead_uuid: site_seller_lead_uuid
      }

      {:ok, _} = Calendars.schedule_tour(params)

      assert tour_appointment = Repo.one(TourAppointment)
      assert listing_uuid == tour_appointment.listing_uuid
      assert site_seller_lead_uuid == tour_appointment.site_seller_lead_uuid
      refute tour_appointment.option

      assert_receive %{new: _, topic: "tour_appointment", type: :new}
    end
  end
end
