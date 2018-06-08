defmodule ReWeb.ListingController do
  use ReWeb, :controller
  use ReWeb.GuardedController

  alias Re.{
    Addresses,
    Listings
  }

  @visualizations Application.get_env(:re, :visualizations, Re.Stats.Visualizations)
  @emails Application.get_env(:re, :emails, ReWeb.Notifications.Emails)

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

  def index(conn, params, user) do
    result = Listings.paginated(params)

    render(
      conn,
      get_view(user),
      "index.json",
      listings: result.listings,
      remaining_count: result.remaining_count
    )
  end

  def create(conn, %{"listing" => listing_params, "address" => address_params} = params, user) do
    with :ok <- Bodyguard.permit(Listings, :create_listing, user, params),
         {:ok, address, _changeset} <- Addresses.insert_or_update(address_params),
         {:ok, listing} <- Listings.insert(listing_params, address, user) do
      send_email_if_not_admin(listing, user)

      conn
      |> put_status(:created)
      |> render(get_view(user), "create.json", listing: listing)
    end
  end

  def show(conn, %{"id" => id}, user) do
    with {:ok, listing} <- Listings.get_preloaded(id),
         :ok <- Bodyguard.permit(Listings, :show_listing, user, listing) do
      @visualizations.listing(listing, user, extract_details(conn))

      render(conn, get_view(user, listing), "show.json", listing: listing)
    end
  end

  def edit(conn, %{"id" => id}, user) do
    with {:ok, listing} <- Listings.get_preloaded(id),
         :ok <- Bodyguard.permit(Listings, :edit_listing, user, listing),
         do: render(conn, get_view(user), "edit.json", listing: listing)
  end

  def update(conn, %{"id" => id, "listing" => listing_params, "address" => address_params}, user) do
    with {:ok, listing} <- Listings.get_preloaded(id),
         :ok <- Bodyguard.permit(Listings, :update_listing, user, listing),
         {:ok, address, address_changeset} <- Addresses.insert_or_update(address_params),
         {:ok, listing, listing_changeset} <-
           Listings.update(listing, listing_params, address, user) do
      send_email_if_not_admin(listing, user, listing_changeset, address_changeset)

      render(conn, get_view(user), "edit.json", listing: listing)
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
    @emails.listing_added(user, listing)

    @emails.listing_added_admin(user, listing)
  end

  defp send_email_if_not_admin(_listing, %{role: "admin"}), do: :nothing

  defp send_email_if_not_admin(
         listing,
         %{role: "user"} = user,
         listing_changeset,
         address_changeset
       ) do
    changes = Enum.concat(listing_changeset.changes, address_changeset.changes)
    @emails.listing_updated(user, listing, changes)
  end

  defp send_email_if_not_admin(_, %{role: "admin"}, _, _), do: :nothing

  defp get_view(%{role: "admin"}), do: ReWeb.ListingAdminView
  defp get_view(_), do: ReWeb.ListingView
  defp get_view(%{role: "admin"}, _), do: ReWeb.ListingAdminView
  defp get_view(%{id: id}, %{user_id: id}), do: ReWeb.ListingAdminView
  defp get_view(_, _), do: ReWeb.ListingView
end
