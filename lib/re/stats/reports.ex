defmodule Re.Stats.Reports do
  @moduledoc """
  Module for reporting listing stats to users
  """
  import Ecto.Query

  alias Re.{
    Listing,
    Repo,
    User
  }

  alias ReWeb.Notifications.Emails

  @env Application.get_env(:re, :env)

  def monthly_stats() do
    unless @env in ~w(staging test) do
      time = Timex.now()

      users_to_be_notified()
      |> Enum.map(&generate_report(&1, time))
      |> Enum.each(fn {user, listings} -> Emails.monthly_report(user, listings) end)
    end
  end

  def users_to_be_notified do
    User
    |> preload(listings: ^where(Listing, [l], l.is_active == true))
    |> where([u], u.confirmed == true and u.role == "user")
    |> order_by([u], u.id)
    |> Repo.all()
    |> Enum.filter(fn
      %{listings: []} -> false
      %{listings: nil} -> false
      %{listings: _listings} -> true
    end)
    |> Enum.filter(fn %{notification_preferences: %{email: email}} -> email end)
  end

  def generate_report(user, time) do
    listings =
      user
      |> Map.get(:listings)
      |> Enum.map(&get_listings_stats(&1, time))

    {user, listings}
  end

  def get_listings_stats(listing, time) do
    month = Timex.shift(time, months: -1)

    listing
    |> Repo.preload(
      listings_visualisations:
        from(lv in Re.Stats.ListingVisualization, where: lv.inserted_at > ^month),
      tour_visualisations: from(tv in Re.Stats.TourVisualization, where: tv.inserted_at > ^month),
      in_person_visits: from(ipv in Re.Stats.InPersonVisit, where: ipv.inserted_at > ^month),
      listings_favorites: from(f in Re.Favorite, where: f.inserted_at > ^month),
      interests: from(i in Re.Interest, where: i.inserted_at > ^month)
    )
    |> replace_with_count()
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
