defmodule Re.Statistics.ListingReports do
  @moduledoc """
  Module for reporting listing stats to users
  """
  import Ecto.Query

  alias Re.{
    Listing,
    Repo
  }

  def listing_report(filename \\ "temp/listing_report.csv") do
    Listing
    |> order_by([l], asc: l.id)
    |> preload([:listings_visualisations, :tour_visualisations, :in_person_visits, :address])
    |> Repo.all()
    |> Enum.map(&replace_with_count/1)
    |> to_csv(filename)
  end

  defp to_csv(listings, filename) do
    to_write =
      listings
      |> Enum.map(&encode/1)
      |> Enum.join("\n")
      |> add_header()

    File.rm(filename)
    File.write(filename, to_write)
  end

  defp encode(listing) do
    "#{listing.id}|" <>
      "#{if listing.status == "active", do: "ativo", else: "inativo"}|" <>
      "#{listing.listings_visualisations_count}|" <>
      "#{listing.tour_visualisations_count}|" <>
      "#{listing.in_person_visits_count}|" <>
      "#{listing.price}|" <>
      "#{listing.type}|" <>
      "#{listing.rooms}|" <>
      "#{listing.address.neighborhood}|" <> "#{Timex.to_date(listing.updated_at)}"
  end

  defp add_header(result) do
    "ID|Ativo/inativo|Visualizações|Tours 3D|Visitas|Preço|Tipo|Quartos|Bairro|Data da última modificação\n" <>
      result
  end

  defp replace_with_count(listing) do
    listing
    |> count_listings_visualisations()
    |> count_tour_visualisations()
    |> count_in_person_visits()
  end

  defp count_listings_visualisations(
         %{listings_visualisations: listings_visualisations} = listing
       ) do
    listing
    |> Map.put(:listings_visualisations_count, Enum.count(listings_visualisations))
    |> Map.delete(:listings_visualisations)
  end

  defp count_tour_visualisations(%{tour_visualisations: tour_visualisations} = listing) do
    listing
    |> Map.put(:tour_visualisations_count, Enum.count(tour_visualisations))
    |> Map.delete(:tour_visualisations)
  end

  defp count_in_person_visits(%{in_person_visits: in_person_visits} = listing) do
    listing
    |> Map.put(:in_person_visits_count, Enum.count(in_person_visits))
    |> Map.delete(:in_person_visits)
  end
end
