defmodule ReWeb.Resolvers.Statistics do
  @moduledoc """
  Resolver module for interests
  """
  alias Re.{
    Favorite,
    Interest,
    Listings,
    Statistics,
    Statistics.InPersonVisit,
    Statistics.ListingVisualization,
    Statistics.TourVisualization
  }

  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  def interest_count(listing, _params, %{context: %{loader: loader, current_user: current_user}}) do
    count_stats(loader, Interest, listing, current_user)
  end

  def in_person_visit_count(listing, _params, %{
        context: %{loader: loader, current_user: current_user}
      }) do
    count_stats(loader, InPersonVisit, listing, current_user)
  end

  def listings_favorite_count(listing, _params, %{
        context: %{loader: loader, current_user: current_user}
      }) do
    count_stats(loader, Favorite, listing, current_user)
  end

  def tour_visualisation_count(listing, _params, %{
        context: %{loader: loader, current_user: current_user}
      }) do
    count_stats(loader, TourVisualization, listing, current_user)
  end

  def listing_visualisation_count(listing, _params, %{
        context: %{loader: loader, current_user: current_user}
      }) do
    count_stats(loader, ListingVisualization, listing, current_user)
  end

  defp count_stats(loader, module, listing, user) do
    if Bodyguard.permit?(Listings, :has_admin_rights, user, listing) do
      loader
      |> Dataloader.load(Statistics, {:many, module}, count: listing)
      |> on_load(fn loader ->
        [count] = Dataloader.get(loader, Statistics, {:many, module}, count: listing)
        {:ok, count}
      end)
    else
      {:ok, nil}
    end
  end
end
