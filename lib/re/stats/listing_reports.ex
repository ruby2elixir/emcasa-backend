defmodule Re.Stats.ListingReports do
  @moduledoc """
  Module for reporting listing stats to users
  """
  import Ecto.Query

  alias Re.{
    Listing,
    Repo,
  }

  def listing_report do
    Listing
    |> order_by([l], asc: l.id)
    |> preload(
      [:listings_visualisations,
      :tour_visualisations,
      :in_person_visits,
      :listings_favorites,
      :interests]
    )
    |> Repo.all()
    |> Enum.map(&replace_with_count/1)
    |> to_csv()
  end

  defp to_csv(listings) do
    to_write = listings
      |> Enum.map(&encode/1)
      |> Enum.join("\n")

    File.rm("temp/listing_report.csv")
    File.write("temp/listing_report.csv", to_write)
  end

  defp encode(listing) do
    "#{listing.id}|#{if listing.is_active, do: "ativo", else: "inativo"}|#{listing.listings_visualisations_count}|#{listing.tour_visualisations_count}|#{listing.in_person_visits_count}|#{Timex.to_date(listing.updated_at)}"
  end

  defp replace_with_count(listing) do
    listing
    |> count_listings_visualisations()
    |> count_tour_visualisations()
    |> count_in_person_visits()
    |> count_listings_favorites()
    |> count_interests()
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

  defp count_listings_favorites(%{listings_favorites: listings_favorites} = listing) do
    listing
    |> Map.put(:listings_favorites_count, Enum.count(listings_favorites))
    |> Map.delete(:listings_favorites)
  end

  defp count_interests(%{interests: interests} = listing) do
    listing
    |> Map.put(:interests_count, Enum.count(interests))
    |> Map.delete(:interests)
  end
end
