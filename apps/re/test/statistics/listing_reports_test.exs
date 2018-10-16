defmodule Re.Statistics.ListingReportsTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.Statistics.ListingReports

  describe "listing_report/0" do
    test "should generate csv report of current listings stats" do
      %{id: id1} =
        insert(:listing,
          is_active: true,
          rooms: 1,
          price: 1_000_000,
          address: build(:address, neighborhood: "Botafogo"),
          type: "Apartamento",
          listings_visualisations: build_list(3, :listing_visualisation),
          tour_visualisations: build_list(3, :tour_visualisation),
          in_person_visits: build_list(3, :in_person_visit),
          updated_at: ~N[2018-08-08 10:00:00]
        )

      %{id: id2} =
        insert(:listing,
          is_active: false,
          rooms: 2,
          price: 800_000,
          address: build(:address, neighborhood: "Copacabana"),
          type: "Casa",
          listings_visualisations: build_list(2, :listing_visualisation),
          tour_visualisations: build_list(2, :tour_visualisation),
          in_person_visits: build_list(2, :in_person_visit),
          updated_at: ~N[2018-08-08 10:00:00]
        )

      ListingReports.listing_report("temp/listing_report.csv")

      assert File.read!("temp/listing_report.csv") ==
               "ID|Ativo/inativo|Visualizações|Tours 3D|Visitas|Preço|Tipo|Quartos|Bairro|Data da última modificação\n" <>
                 "#{id1}|ativo|3|3|3|1000000|Apartamento|1|Botafogo|2018-08-08\n" <>
                 "#{id2}|inativo|2|2|2|800000|Casa|2|Copacabana|2018-08-08"
    end
  end
end
