defmodule ReWeb.ListingController do
  use ReWeb, :controller
  use Guardian.Phoenix.Controller

  alias ReWeb.{Listing, Image, Address}

  plug Guardian.Plug.EnsureAuthenticated,
    %{handler: ReWeb.SessionController} when action in [:create, :update, :delete]

  def index(conn, _params, _user, _full_claims) do
    listings = Repo.all(from l in Listing,
      where: l.is_active == true,
      order_by: [desc: l.score],
      order_by: [asc: l.matterport_code])
      |> Repo.preload(:address)
      |> Repo.preload([images: (from i in Image, order_by: i.position)])

    render(conn, "index.json", listings: listings)
  end

  def create(conn, %{"listing" => listing_params, "address" => address_params}, _user, _full_claims) do
    address_changeset = Address.changeset(%Address{}, address_params)
    listing_changeset = %Listing{} |> Listing.changeset(listing_params)

    address_id =
      case Repo.get_by(Address,
                  street: address_params["street"] || "",
                  postal_code: address_params["postal_code"] || "",
                  street_number: address_params["street_number"] || "") do

        nil ->
          case Repo.insert(address_changeset) do
            {:ok, address} -> address.id

            {:error, _} -> nil
          end

        address -> address.id
      end

    IO.inspect address_id

    case address_id do
      nil ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ReWeb.ChangesetView, "error.json", changeset: address_changeset )

      address_id ->
        listing_changeset =
          listing_changeset
          |> Ecto.Changeset.change(address_id: address_id)

        case Repo.insert(listing_changeset) do
          {:ok, listing} ->
            conn
            |> put_status(:created)
            |> render("create.json", listing: listing)

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(ReWeb.ChangesetView, "error.json", changeset: changeset)
        end
    end
  end

  def show(conn, %{"id" => id}, _user, _full_claims) do
    listing =
      from(l in Listing, where: l.is_active == true)
      |> Repo.get!(id)
      |> Repo.preload(:address)
      |> Repo.preload([images: (from i in Image, order_by: i.position)])

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
