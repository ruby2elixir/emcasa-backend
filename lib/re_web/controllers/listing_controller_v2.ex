defmodule ReWeb.ListingControllerV2 do
  @moduledoc false
  use ReWeb, :controller
  use ReWeb.GuardedController

  alias Re.{
    Addresses,
    Listings,
    ListingsV2
  }

  action_fallback(ReWeb.FallbackController)

  plug(Guardian.Plug.EnsureAuthenticated when action in [:create, :update])

  def create(conn, %{"listing" => listing_params, "address" => address_params} = params, user) do
    with :ok <- Bodyguard.permit(Listings, :create_listing, user, params),
         {:ok, address} <- Addresses.find_or_create(address_params),
         {:ok, listing} <- ListingsV2.insert(listing_params, address.id, user.id) do
      conn
      |> put_status(:created)
      |> render(ReWeb.ListingView, "create.json", listing: listing)
    end
  end

  def update(conn, %{"id" => id, "listing" => listing_params, "address" => address_params}, user) do
    with {:ok, listing} <- Listings.get_preloaded(id),
         :ok <- Bodyguard.permit(Listings, :update_listing, user, listing),
         {:ok, address} <- Addresses.update(listing, address_params),
         {:ok, listing} <- ListingsV2.update(listing, listing_params, address.id) do
      render(conn, ReWeb.ListingView, "edit.json", listing: listing)
    end
  end
end
