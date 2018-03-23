defmodule ReWeb.Resolvers.Listings do
  @moduledoc """
  Resolver module for listing queries and mutations
  """
  alias Re.Listings

  def activate(%{id: id}, %{context: %{current_user: current_user}}) do
    case Bodyguard.permit(Listings, :activate_listing, current_user, %{}) do
      :ok -> do_activate(id)
      _error -> {:error, :unauthorized}
    end
  end

  def deactivate(%{id: id}, %{context: %{current_user: current_user}}) do
    case Bodyguard.permit(Listings, :deactivate_listing, current_user, %{}) do
      :ok -> do_deactivate(id)
      _error -> {:error, :unauthorized}
    end
  end

  def favorite(%{id: id}, %{context: %{current_user: current_user}}) do
    case Bodyguard.permit(Listings, :favorite_listing, current_user, %{}) do
      :ok -> do_favorite(id, current_user)
      _error -> {:error, :unauthorized}
    end
  end

  def unfavorite(%{id: id}, %{context: %{current_user: current_user}}) do
    case Bodyguard.permit(Listings, :unfavorite_listing, current_user, %{}) do
      :ok -> do_unfavorite(id, current_user)
      _error -> {:error, :unauthorized}
    end
  end

  defp do_activate(id) do
    case Listings.get(id) do
      {:ok, listing} -> Listings.activate(listing)
      {:error, :not_found} -> {:error, "Listing ID #{id} not found"}
    end
  end

  defp do_deactivate(id) do
    case Listings.get(id) do
      {:ok, listing} -> Listings.delete(listing)
      {:error, :not_found} -> {:error, "Listing ID #{id} not found"}
    end
  end

  defp do_favorite(id, user) do
    case Listings.get(id) do
      {:ok, listing} -> Listings.favorite(listing, user)
      {:error, :not_found} -> {:error, "Listing ID #{id} not found"}
    end
  end

  defp do_unfavorite(id, user) do
    case Listings.get(id) do
      {:ok, listing} -> Listings.unfavorite(listing, user)
      {:error, :not_found} -> {:error, "Listing ID #{id} not found"}
    end
  end
end
