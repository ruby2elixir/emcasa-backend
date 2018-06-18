defmodule ReWeb.Resolvers.Listings do
  @moduledoc """
  Resolver module for listing queries and mutations
  """
  alias Re.{
    Addresses,
    Listings
  }

  def index(params, _) do
    pagination = Map.get(params, :pagination, %{})
    filtering = Map.get(params, :filters, %{})

    {:ok, Listings.paginated(Map.merge(pagination, filtering))}
  end

  def show(%{id: id}, _), do: Listings.get(id)

  def insert(%{input: %{address: address_params} = listing_params}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :create_listing, current_user, listing_params),
         {:ok, address, _changeset} <- Addresses.insert_or_update(address_params),
         do: Listings.insert(listing_params, address, current_user)
  end

  def activate(%{id: id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :activate_listing, current_user, %{}),
         {:ok, listing} <- Listings.get_preloaded(id),
         do: Listings.activate(listing)
  end

  def deactivate(%{id: id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :deactivate_listing, current_user, %{}),
         {:ok, listing} <- Listings.get(id),
         do: Listings.deactivate(listing)
  end

  def per_user(_, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :per_user, current_user, %{}),
         do: {:ok, Listings.per_user(current_user)}
  end
end
