defmodule ReWeb.Resolvers.Addresses do
  @moduledoc """
  Resolver module for addresses
  """

  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias Re.{
    Addresses,
    Addresses.Neighborhoods,
    Districts,
    Development,
    Developments,
    Listing,
    Listings
  }

  def per_listing(listing, params, %{context: %{current_user: current_user}}) do
    admin = has_admin_rights?(current_user, listing)

    {:address, Map.put(params, :has_admin_rights, admin)}
  end

  def per_development(development, params, %{context: %{current_user: current_user}}) do
    admin = has_admin_rights?(current_user, development)

    {:address, Map.put(params, :has_admin_rights, admin)}
  end

  def insert(%{input: params}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Addresses, :insert, current_user, %{}),
         {:ok, address} <- Addresses.insert_or_update(params) do
      {:ok, address}
    end
  end

  def neighborhood_description(address, _, _) do
    case Neighborhoods.get_description(address) do
      {:ok, district} -> {:ok, district.description}
      {:error, :not_found} -> {:ok, nil}
    end
  end

  def districts(_, _), do: {:ok, Neighborhoods.districts()}

  def districts_by_broker_user(user, _, %{context: %{loader: loader}}) do
    loader
    |> Dataloader.load(Districts, :districts, user)
    |> on_load(fn loader ->
      {:ok, Dataloader.get(loader, Districts, :districts, user)}
    end)
  end

  def district(params, _), do: Neighborhoods.get_district(params)

  def is_covered(params, _) do
    {:ok, Addresses.is_covered(params)}
  end

  def is_covered(address, _, _), do: {:ok, Addresses.is_covered(address)}

  def neighborhoods(_, _), do: {:ok, Neighborhoods.all()}

  defp has_admin_rights?(user, %Listing{} = listing) do
    Bodyguard.permit?(Listings, :has_admin_rights, user, listing)
  end

  defp has_admin_rights?(user, %Development{} = development) do
    Bodyguard.permit?(Developments, :has_admin_rights, user, development)
  end
end
