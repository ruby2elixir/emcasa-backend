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

  def index(conn, params, _user) do
    result = Listings.paginated(params)

    render(
      conn,
      "index.json",
      listings: result.listings,
      remaining_count: result.remaining_count
    )
  end

  def create(conn, %{"listing" => listing_params, "address" => address_params} = params, user) do
    with :ok <- Bodyguard.permit(Listings, :create_listing, user, params),
         {:ok, address} <- Addresses.find_or_create(address_params),
         {:ok, listing} <- Listings.insert(listing_params, address, user) do
      send_email_if_not_admin(listing, user)

      conn
      |> put_status(:created)
      |> render("create.json", listing: listing)
    end
  end

  def show(conn, %{"id" => id}, user) do
    with {:ok, listing} <- Listings.get_preloaded(id),
         :ok <- Bodyguard.permit(Listings, :show_listing, user, listing) do
      @visualizations.listing(listing, user, extract_details(conn))

      render(conn, "show.json", listing: listing)
    end
  end

  def edit(conn, %{"id" => id}, user) do
    with {:ok, listing} <- Listings.get_preloaded(id),
         :ok <- Bodyguard.permit(Listings, :edit_listing, user, listing),
         do: render(conn, "edit.json", listing: listing)
  end

  def update(conn, %{"id" => id, "listing" => listing_params, "address" => address_params}, user) do
    with {:ok, listing} <- Listings.get_preloaded(id),
         :ok <- Bodyguard.permit(Listings, :update_listing, user, listing),
         {:ok, address} <- Addresses.update(listing, address_params),
         {:ok, listing, changeset} <- Listings.update(listing, listing_params, address, user) do
      send_email_if_not_admin(listing, user, changeset)

      render(conn, "edit.json", listing: listing)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    with {:ok, listing} <- Listings.get(id),
         :ok <- Bodyguard.permit(Listings, :delete_listing, user, listing),
         {:ok, _listing} <- Listings.deactivate(listing),
         do: send_resp(conn, :no_content, "")
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

  def send_email_if_not_admin(listing, %{role: "user"} = user, changeset) do
    @emails.listing_updated(user, listing, changeset)
  end

  def send_email_if_not_admin(_, %{role: "admin"}, _), do: :nothing
end
