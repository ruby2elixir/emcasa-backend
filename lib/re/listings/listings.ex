defmodule Re.Listings do
  @moduledoc """
  Context for listings.
  """
  @behaviour Bodyguard.Policy

  import Ecto.Query

  alias Re.{
    Addresses,
    Listing,
    Listings.FeaturedListing,
    Listings.Filter,
    Image,
    Repo
  }

  alias Ecto.Changeset

  defdelegate authorize(action, user, params), to: Re.Listings.Policy

  @active_listings_query from(l in Listing, where: l.is_active == true)
  @order_by_position from(i in Image, where: i.is_active == true, order_by: i.position)

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

  def featured do
    FeaturedListing
    |> order_by([fl], asc: fl.position)
    |> preload([:listing, listing: [:address, images: ^@order_by_position]])
    |> Repo.all()
    |> Enum.map(&Map.get(&1, :listing))
    |> check_if_exists()
  end

  def related(listing) do
    query = from(l in @active_listings_query, where: l.id != ^listing.id)
    do_related(~w(garage_spots batahrooms rooms type)a, listing, query)
  end

  defp do_related([], _, _) do
    [listing | _] = featured()
    {:ok, listing}
  end

  defp do_related([_attr | rest] = attrs, listing, query) do
    listing
    |> Map.take(attrs)
    |> Enum.reduce(query, &build_query(&1, &2))
    |> Repo.all()
    |> case do
      [] -> do_related(rest, listing, query)
      [listing | _] -> {:ok, listing}
    end
  end

  defp build_query({key, value}, query) do
    from(l in query, where: field(l, ^key) == ^value)
  end

  @top_4_listings_query from(l in Listing, where: l.is_active == true, order_by: [desc: l.score])

  defp check_if_exists([_, _, _, _] = featured), do: featured

  defp check_if_exists(_) do
    @top_4_listings_query
    |> preload([:address, images: ^@order_by_position])
    |> Repo.all()
  end
end
