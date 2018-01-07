defmodule Re.Listings do
  @moduledoc """
  Context for listings.
  """

  import Ecto.Query

  alias Re.{
    Addresses,
    Listing,
    Listings.Filter,
    Image,
    Repo
  }
  alias Ecto.Changeset

  @active_listings_query from l in Listing, where: l.is_active == true
  @order_by_position from i in Image, order_by: i.position

  defp old_all(params) do
    @active_listings_query
    |> order_by([l], desc: l.score, asc: l.matterport_code)
    |> maybe_get_address_ids_with_neighborhood(params["neighborhood"])
    |> Filter.apply(params)
    |> Ecto.Query.preload([:address, images: ^@order_by_position])
  end

  def all(params) do
    params
    |> old_all()
    |> Repo.all()
  end

  def paginated(params) do
    params
    |> old_all()
    |> Repo.paginate(params)
  end

  def maybe_get_address_ids_with_neighborhood(query, nil), do: query
  def maybe_get_address_ids_with_neighborhood(query, neighborhood) do
    ids = Addresses.get_ids_with_neighborhood(neighborhood)
    query
    |> where([l], l.address_id in ^ids)
  end

  def get(id) do
    case Repo.get(@active_listings_query, id) do
      nil -> {:error, :not_found}
      listing -> {:ok, listing}
    end
  end

  def preload(listing), do: {:ok, Repo.preload(listing, [:address, images: @order_by_position])}

  def insert(listing_params, address_id) do
    %Listing{}
    |> Listing.changeset(Map.put(listing_params, "address_id", address_id))
    |> Repo.insert()
  end

  def update(listing, listing_params, address_id) do
    listing
    |> Listing.changeset(listing_params)
    |> Changeset.change(address_id: address_id)
    |> Repo.update()
  end

  def delete(listing), do: Repo.delete(listing)

end
