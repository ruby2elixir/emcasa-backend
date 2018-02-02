defmodule Re.Listings do
  @moduledoc """
  Context for listings.
  """
  @behaviour Bodyguard.Policy

  import Ecto.Query

  alias Re.{
    Addresses,
    Listing,
    Listings.Filter,
    Image,
    Repo
  }

  alias Ecto.Changeset

  defdelegate authorize(action, user, params), to: Re.Listings.Policy
  defdelegate featured(), to: Re.Listings.Featured

  @active_listings_query from(l in Listing, where: l.is_active == true)
  @order_by_position from(i in Image, where: i.is_active == true, order_by: i.position)
  def active_listings_query, do: @active_listings_query
  def order_by_position, do: @order_by_position

  def paginated(params) do
    @active_listings_query
    |> order_by([l], desc: l.score, asc: l.matterport_code)
    |> maybe_get_address_ids_with_neighborhood(params["neighborhood"])
    |> Filter.apply(params)
    |> preload([:address, images: ^@order_by_position])
    |> Repo.paginate(params)
  end

  def maybe_get_address_ids_with_neighborhood(query, nil), do: query

  def maybe_get_address_ids_with_neighborhood(query, neighborhood) do
    ids = Addresses.get_ids_with_neighborhood(neighborhood)

    query
    |> where([l], l.address_id in ^ids)
  end

  def get(id) do
    get(Listing, id)
  end

  def get_preloaded(id) do
    @active_listings_query
    |> preload([:address, images: ^@order_by_position])
    |> get(id)
  end

  defp get(query, id) do
    case Repo.get(query, id) do
      nil -> {:error, :not_found}
      listing -> {:ok, listing}
    end
  end

  def insert(listing_params, address_id, user_id) do
    listing_params =
      listing_params
      |> Map.put("address_id", address_id)
      |> Map.put("user_id", user_id)

    %Listing{}
    |> Listing.changeset(listing_params)
    |> Repo.insert()
  end

  def update(listing, listing_params, address_id) do
    listing
    |> Listing.changeset(listing_params)
    |> Changeset.change(address_id: address_id)
    |> Repo.update()
  end

  def delete(listing) do
    listing
    |> Changeset.change(is_active: false)
    |> Repo.update()
  end
end
