defmodule ReWeb.Resolvers.Favorites do
  @moduledoc """
  Resolver module for listing queries and mutations
  """

  alias Re.{
    Favorites,
    Listings
  }

  def add(%{id: id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Favorites, :favorite_listing, current_user, %{}),
         {:ok, listing} <- Listings.get(id),
         {:ok, _} <- Favorites.add(listing, current_user) do
      {:ok, %{listing: listing, user: current_user}}
    end
  end

  def remove(%{id: id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Favorites, :unfavorite_listing, current_user, %{}),
         {:ok, listing} <- Listings.get(id),
         {:ok, _} <- Favorites.remove(listing, current_user) do
      {:ok, %{listing: listing, user: current_user}}
    end
  end

  def users(%{id: id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Favorites, :show_favorited_users, current_user, %{}),
         {:ok, listing} <- Listings.get(id) do
      {:ok, Favorites.users(listing)}
    end
  end
end
