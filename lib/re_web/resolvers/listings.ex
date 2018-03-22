defmodule ReWeb.Resolvers.Listings do
  @moduledoc """
  Resolver module for listing queries and mutations
  """
  alias Re.Listings

  def all(_args, _resolution) do
    page = Listings.paginated()
    {:ok, page.entries}
  end

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

  def do_activate(id) do
    case Listings.get(id) do
      {:ok, listing} -> Listings.activate(listing)
      {:error, :not_found} -> {:error, "Listing ID #{id} not found"}
    end
  end

  def do_deactivate(id) do
    case Listings.get(id) do
      {:ok, listing} -> Listings.delete(listing)
      {:error, :not_found} -> {:error, "Listing ID #{id} not found"}
    end
  end
end
