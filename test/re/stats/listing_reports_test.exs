defmodule Re.Stats.ListingReportsTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.Stats.ListingReports

  describe "listing_report/0" do
    test "should generate csv report of current listings stats" do
      %{id: id1} = insert(:listing, is_active: true, listings_visualisations: build_list(3, :listing_visualisation), tour_visualisations: build_list(3, :tour_visualisation), in_person_visits: build_list(3, :in_person_visit), updated_at: ~N[2018-08-08 10:00:00])
      %{id: id2} = insert(:listing, is_active: false, listings_visualisations: build_list(2, :listing_visualisation), tour_visualisations: build_list(2, :tour_visualisation), in_person_visits: build_list(2, :in_person_visit), updated_at: ~N[2018-08-08 10:00:00])

      ListingReports.listing_report()

      assert File.read!("temp/listing_report.csv") ==
      "#{id1}|ativo|3|3|3|2018-08-08\n" <>
      "#{id2}|inativo|2|2|2|2018-08-08"
    end
  end
end
