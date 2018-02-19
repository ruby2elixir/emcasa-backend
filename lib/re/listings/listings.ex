defmodule Re.Listings do
  @moduledoc """
  Context for listings.
  """
  @behaviour Bodyguard.Policy

  import Ecto.Query

  alias Re.{
    Listing,
    Listings.Filter,
    Image,
    Repo
  }

  alias Ecto.Changeset

  defdelegate authorize(action, user, params), to: Re.Listings.Policy

  def active_listings_query(query \\ Listing), do: from(l in query, where: l.is_active == true)

  @order_by_position from(i in Image, where: i.is_active == true, order_by: i.position)
  def order_by_position, do: @order_by_position

  def paginated(params) do
    active_listings_query()
    |> order_by([l], desc: l.score, asc: l.matterport_code)
    |> Filter.apply(params)
    |> preload([:address, images: ^@order_by_position])
    |> Repo.paginate(params)
  end

  def relaxed(params, types) do
    active_listings_query()
    |> order_by([l], desc: l.score, asc: l.matterport_code)
    |> exclude_listings(params)
    |> Filter.relax(params, types)
    |> preload([:address, images: ^@order_by_position])
    |> Repo.all()
  end

  def get(id), do: do_get(Listing, id)

  def get_preloaded(id) do
    active_listings_query()
    |> preload([:address, images: ^@order_by_position])
    |> do_get(id)
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

  defp do_get(query, id) do
    case Repo.get(query, id) do
      nil -> {:error, :not_found}
      listing -> {:ok, listing}
    end
  end

  defp exclude_listings(query, %{"exclude_listings" => ids}) do
    from(l in query, where: l.id not in ^ids)
  end
end
