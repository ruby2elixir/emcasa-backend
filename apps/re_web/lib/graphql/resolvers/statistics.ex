defmodule ReWeb.Resolvers.Statistics do
  @moduledoc """
  Resolver module for interests
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  def interest_count(listing, _params, %{context: %{loader: loader, current_user: current_user}}) do
    count_stats(loader, Re.Interest, listing, current_user)
  end

  def in_person_visit_count(listing, _params, %{
        context: %{loader: loader, current_user: current_user}
      }) do
    count_stats(loader, Re.Statistics.InPersonVisit, listing, current_user)
  end

  def listings_favorite_count(listing, _params, %{
        context: %{loader: loader, current_user: current_user}
      }) do
    count_stats(loader, Re.Favorite, listing, current_user)
  end

  def tour_visualisation_count(listing, _params, %{
        context: %{loader: loader, current_user: current_user}
      }) do
    count_stats(loader, Re.Statistics.TourVisualization, listing, current_user)
  end

  def listing_visualisation_count(listing, _params, %{
        context: %{loader: loader, current_user: current_user}
      }) do
    count_stats(loader, Re.Statistics.ListingVisualization, listing, current_user)
  end

  defp count_stats(loader, module, listing, user) do
    if is_admin(listing, user) do
      loader
      |> Dataloader.load(Re.Statistics, {:many, module}, count: listing)
      |> on_load(fn loader ->
        [count] = Dataloader.get(loader, Re.Statistics, {:many, module}, count: listing)
        {:ok, count}
      end)
    else
      {:ok, nil}
    end
  end

  defp is_admin(%{user_id: user_id}, %{id: user_id}), do: true
  defp is_admin(_, %{role: "admin"}), do: true
  defp is_admin(_, _), do: false
end
