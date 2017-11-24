defmodule ReWeb.ListingController do
  use ReWeb, :controller

  alias ReWeb.Listing

  def index(conn, _params) do
    listings = Repo.all from l in Listing,
      where: l.is_active == true,
      order_by: [desc: l.score],
      order_by: [asc: l.matterport_code],
      preload: [:address]

    render(conn, "index.json", listings: listings)
  end

  def create(conn, %{"listing" => listing_params}) do
    changeset = Listing.changeset(%Listing{}, listing_params)

    case Repo.insert(changeset) do
      {:ok, listing} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", listing_path(conn, :show, listing))
        |> render("show.json", listing: listing)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ReWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    listing =
      from(l in Listing, where: l.is_active == true)
      |> Repo.get!(id) |> Repo.preload(:address)

    render(conn, "show.json", listing: listing)
  end

  def update(conn, %{"id" => id, "listing" => listing_params}) do
    listing = Repo.get!(Listing, id)
    changeset = Listing.changeset(listing, listing_params)

    case Repo.update(changeset) do
      {:ok, listing} ->
        render(conn, "show.json", listing: listing)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ReWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    listing = Repo.get!(Listing, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(listing)

    send_resp(conn, :no_content, "")
  end
end
