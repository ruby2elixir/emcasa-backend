defmodule ReWeb.Resolvers.Blacklists do
  @moduledoc """
  Resolver module for blacklist queries and mutations
  """

  alias Re.{
    Blacklists,
    Listings
  }

  def add(%{id: id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Blacklists, :blacklist_listing, current_user, %{}),
         {:ok, listing} <- Listings.get(id),
         {:ok, _} <- Blacklists.add(listing, current_user) do
      {:ok, %{listing: listing, user: current_user}}
    end
  end

  def remove(%{id: id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Blacklists, :unblacklist_listing, current_user, %{}),
         {:ok, listing} <- Listings.get(id),
         {:ok, _} <- Blacklists.remove(listing, current_user) do
      {:ok, %{listing: listing, user: current_user}}
    end
  end

  def users(%{id: id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Blacklists, :show_blacklisted_users, current_user, %{}),
         {:ok, listing} <- Listings.get(id) do
      {:ok, Blacklists.users(listing)}
    end
  end
end
