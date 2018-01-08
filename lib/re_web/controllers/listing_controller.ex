defmodule ReWeb.ListingController do
  use ReWeb, :controller
  use Guardian.Phoenix.Controller

  alias Re.{
    Addresses,
    Images,
    Listings
  }

  plug Guardian.Plug.EnsureAuthenticated,
    %{handler: ReWeb.SessionController}
    when action in [:create, :edit, :update, :delete, :order]

  action_fallback ReWeb.FallbackController

  def index(conn, params, _user, _full_claims) do
    page = Listings.paginated(params)
    render(conn, "index.json",
      listings: page.entries,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries
    )
  end

  def create(conn, %{"listing" => listing_params, "address" => address_params}, _user, _full_claims) do
    with {:ok, address} <- Addresses.find_or_create(address_params),
         {:ok, listing} <- Listings.insert(listing_params, address.id)
      do
        conn
        |> put_status(:created)
        |> render("create.json", listing: listing)
    end
  end

  def show(conn, %{"id" => id}, _user, _full_claims) do
    with {:ok, listing} <- Listings.get(id),
         {:ok, listing} <- Listings.preload(listing),
      do: render(conn, "show.json", listing: listing)
  end

  def edit(conn, %{"id" => id}, _user, _full_claims) do
    with {:ok, listing} <- Listings.get(id),
         {:ok, listing} <- Listings.preload(listing),
      do: render(conn, "edit.json", listing: listing)
  end

  def update(conn, %{"id" => id, "listing" => listing_params, "address" => address_params}, _user, _full_claims) do
    with {:ok, listing} <- Listings.get(id),
         {:ok, listing} <- Listings.preload(listing),
         {:ok, address} <- Addresses.update(listing, address_params),
         {:ok, listing} <- Listings.update(listing, listing_params, address.id),
      do: render(conn, "edit.json", listing: listing)
  end

  def delete(conn, %{"id" => id}, _user, _full_claims) do
    with {:ok, listing} <- Listings.get(id),
         {:ok, _listing} <- Listings.delete(listing),
      do: send_resp(conn, :no_content, "")
  end

  def order(conn, %{"listing_id" => id, "images" => images_params}, _user, _full_claims) do
    with {:ok, listing} <- Listings.get(id),
         :ok <- Images.update_per_listing(listing, images_params),
      do: send_resp(conn, :no_content, "")
  end
end
