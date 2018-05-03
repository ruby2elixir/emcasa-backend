defmodule ReWeb.Resolvers.Listings do
  @moduledoc """
  Resolver module for listing queries and mutations
  """
  alias Re.Listings
  alias ReWeb.Search

  @elasticsearch Application.get_env(:re, :elasticsearch, Search)

  def activate(%{id: id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :activate_listing, current_user, %{}),
         {:ok, listing} <- Listings.get_preloaded(id),
         {:ok, listing} <- Listings.activate(listing),
         :ok <- @elasticsearch.put_document(listing) do
      {:ok, listing}
    end
  end

  def deactivate(%{id: id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :deactivate_listing, current_user, %{}),
         {:ok, listing} <- Listings.get(id),
         {:ok, listing} <- Listings.deactivate(listing),
         :ok <- @elasticsearch.delete_document(listing) do
      {:ok, listing}
    end
  end
end
