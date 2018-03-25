defmodule ReWeb.Resolvers.Listings do
  @moduledoc """
  Resolver module for listing queries and mutations
  """
  alias Re.Listings

  def activate(%{id: id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :activate_listing, current_user, %{}),
         {:ok, listing} <- Listings.get(id) do
      Listings.activate(listing)
    end
  end

  def deactivate(%{id: id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :deactivate_listing, current_user, %{}),
         {:ok, listing} <- Listings.get(id) do
      Listings.delete(listing)
    end
  end

  def favorite(%{id: id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :favorite_listing, current_user, %{}),
         {:ok, listing} <- Listings.get(id) do
      Listings.favorite(listing, current_user)
    end
  end

  def unfavorite(%{id: id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :unfavorite_listing, current_user, %{}),
         {:ok, listing} <- Listings.get(id) do
      Listings.unfavorite(listing, current_user)
    end
  end

  def favorited_users(%{id: id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :show_favorited_users, current_user, %{}),
         {:ok, listing} <- Listings.get(id) do
      {:ok, Listings.favorited_users(listing)}
    end
  end
end
