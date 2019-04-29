defmodule ReWeb.ListingController do
  use ReWeb, :controller
  use ReWeb.GuardedController

  alias Re.{
    Addresses,
    Listings
  }

  @visualizations Application.get_env(:re, :visualizations, Re.Statistics.Visualizations)
  @emails Application.get_env(:re_integrations, :emails, ReIntegrations.Notifications.Emails)

  action_fallback(ReWeb.FallbackController)

  plug(
    Guardian.Plug.EnsureAuthenticated
    when action in [
           :create,
           :edit,
           :update,
           :delete,
           :order
         ]
  )

  def create(conn, %{"listing" => listing_params, "address" => address_params} = params, user) do
    with :ok <- Bodyguard.permit(Listings, :create_listing, user, params),
         {:ok, address} <- Addresses.insert_or_update(address_params),
         {:ok, listing} <- Listings.insert(listing_params, address: address, user: user) do
      send_email_if_not_admin(listing, user)

      conn
      |> put_status(:created)
      |> put_view(get_view(user))
      |> render("create.json", listing: listing)
    end
  end

  def show(conn, %{"id" => id}, user) do
    with {:ok, listing} <- Listings.get_preloaded(id),
         :ok <- Bodyguard.permit(Listings, :show_listing, user, listing) do
      @visualizations.listing(listing, user, extract_details(conn))

      conn
      |> put_view(get_view(user, listing))
      |> render("show.json", listing: listing)
    end
  end

  def edit(conn, %{"id" => id}, user) do
    with {:ok, listing} <- Listings.get_preloaded(id),
         :ok <- Bodyguard.permit(Listings, :edit_listing, user, listing) do
      conn
      |> put_view(get_view(user))
      |> render("edit.json", listing: listing)
    end
  end

  def update(conn, %{"id" => id, "listing" => listing_params, "address" => address_params}, user) do
    with {:ok, listing} <- Listings.get_preloaded(id),
         :ok <- Bodyguard.permit(Listings, :update_listing, user, listing),
         {:ok, address} <- Addresses.insert_or_update(address_params),
         {:ok, listing} <- Listings.update(listing, listing_params, address: address, user: user) do
      conn
      |> put_view(get_view(user))
      |> render("edit.json", listing: listing)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    with {:ok, listing} <- Listings.get(id),
         :ok <- Bodyguard.permit(Listings, :delete_listing, user, listing),
         {:ok, _listing} <- Listings.deactivate(listing),
         do: send_resp(conn, :no_content, "")
  end

  def coordinates(conn, _, _) do
    render(conn, "coordinates.json", listings: Listings.coordinates())
  end

  @visualization_params ~w(remote_ip req_headers)a

  defp extract_details(conn) do
    conn
    |> Map.take(@visualization_params)
    |> Kernel.inspect()
  end

  defp send_email_if_not_admin(listing, %{role: "user"} = user) do
    @emails.listing_added_admin(user, listing)
  end

  defp send_email_if_not_admin(_listing, %{role: "admin"}), do: :nothing

  defp get_view(%{role: "admin"}), do: ReWeb.ListingAdminView
  defp get_view(_), do: ReWeb.ListingView
  defp get_view(%{role: "admin"}, _), do: ReWeb.ListingAdminView
  defp get_view(%{id: id}, %{user_id: id}), do: ReWeb.ListingAdminView
  defp get_view(_, _), do: ReWeb.ListingView
end
