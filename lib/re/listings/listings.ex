defmodule Re.Listings do
  @moduledoc """
  Context for listings.
  """
  @behaviour Bodyguard.Policy

  alias Re.{
    Listings.Favorite,
    Listing,
    Listings.Filter,
    Listings.Queries,
    Listings.Opts,
    Repo
  }

  alias Ecto.Changeset

  defdelegate authorize(action, user, params), to: Re.Listings.Policy

  def all do
    Queries.active()
    |> Queries.order_by_id()
    |> Repo.all()
  end

  def paginated(params \\ %{}) do
    query = build_query(params)

    %{
      remaining_count: remaining_count(query, params),
      listings: Repo.all(query)
    }
  end

  def remaining_count(query, params) do
    query
    |> Queries.remaining_count()
    |> Repo.one()
    |> calculate_remaining(params)
  end

  defp calculate_remaining(count, params) do
    opts = Opts.build(params)

    case (count || 0) - (opts.page_size + length(opts.excluded_listings_ids)) do
      num when num > 0 -> num
      _ -> 0
    end
  end

  defp build_query(params) do
    Queries.active()
    |> Queries.excluding(params)
    |> Queries.order_by()
    |> Queries.limit(params)
    |> Queries.preload()
    |> Filter.apply(params)
  end

  def get(id), do: do_get(Listing, id)

  def get_preloaded(id), do: do_get(Queries.preload(), id)

  def insert(params, address, user) do
    %Listing{}
    |> Changeset.change(address_id: address.id)
    |> Changeset.change(user_id: user.id)
    |> Listing.changeset(params, user.role)
    |> Repo.insert()
  end

  def update(listing, params, address, user) do
    listing
    |> Changeset.change(address_id: address.id)
    |> Listing.changeset(params, user.role)
    |> Repo.update()
  end

  def delete(listing) do
    listing
    |> Changeset.change(is_active: false)
    |> Repo.update()
  end

  def activate(listing) do
    listing
    |> Changeset.change(is_active: true)
    |> Repo.update()
  end

  def favorite(listing, user) do
    %Favorite{}
    |> Changeset.change(listing_id: listing.id)
    |> Changeset.change(user_id: user.id)
    |> Repo.insert()
  end

  def unfavorite(listing, user) do
    case Repo.get_by(Favorite, listing_id: listing.id, user_id: user.id) do
      nil -> {:error, :not_found}
      favorite -> Repo.delete(favorite)
    end
  end

  def favorited_users(listing) do
    listing
    |> Repo.preload(:favorited)
    |> Map.get(:favorited)
  end

  defp do_get(query, id) do
    case Repo.get(query, id) do
      nil -> {:error, :not_found}
      listing -> {:ok, listing}
    end
  end
end
