defmodule ReWeb.ListingController do
  use ReWeb, :controller
  use ReWeb.GuardedController

  alias Re.{
    Addresses,
    Listings,
    Stats.Visualizations
  }

  @visualizations Application.get_env(:re, :visualizations, Visualizations)

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
    page = Listings.paginated(params)

    render(
      conn,
      "paginated_index.json",
      listings: page.entries,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries
    )
  end

  def create(conn, %{"listing" => listing_params, "address" => address_params} = params, user) do
    with :ok <- Bodyguard.permit(Listings, :create_listing, user, params),
         {:ok, address} <- Addresses.find_or_create(address_params),
         {:ok, listing} <- Listings.insert(listing_params, address.id, user) do
      conn
      |> put_status(:created)
      |> render("create.json", listing: listing)
    end
  end

  def show(conn, %{"id" => id}, user) do
    with {:ok, listing} <- Listings.get_preloaded(id),
         {:ok, listing} <- Listings.should_show(listing, user) do
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
         {:ok, listing} <- Listings.update(listing, listing_params, address.id),
         do: render(conn, "edit.json", listing: listing)
  end

  def delete(conn, %{"id" => id}, user) do
    with {:ok, listing} <- Listings.get(id),
         :ok <- Bodyguard.permit(Listings, :delete_listing, user, listing),
         {:ok, _listing} <- Listings.delete(listing),
         do: send_resp(conn, :no_content, "")
  end

  @visualization_params ~w(remote_ip req_headers)a

  defp extract_details(conn) do
    conn
    |> Map.take(@visualization_params)
    |> Kernel.inspect()
  end
end
