defmodule Re.Listings do
  @moduledoc """
  Context for listings.
  """
  @behaviour Bodyguard.Policy

  alias Re.{
    Listing,
    Filtering,
    Images,
    Listings.Queries,
    Listings.Opts,
    Repo
  }

  alias Ecto.Changeset

  defdelegate authorize(action, user, params), to: Re.Listings.Policy

  def all do
    Queries.active()
    |> Queries.preload_relations([:address])
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

    case count - opts.page_size do
      num when num > 0 -> num
      _ -> 0
    end
  end

  @partial_preload [
    :address,
    :listings_favorites,
    images: Images.Queries.listing_preload()
  ]

  defp build_query(params) do
    Queries.active()
    |> Queries.excluding(params)
    |> Queries.order_by()
    |> Queries.limit(params)
    |> Queries.preload_relations(@partial_preload)
    |> Filtering.apply(params)
  end

  def get(id), do: do_get(Listing, id)

  def get_preloaded(id), do: do_get(Queries.preload_relations(), id)

  def insert(params, address, user) do
    %Listing{}
    |> Changeset.change(address_id: address.id)
    |> Changeset.change(user_id: user.id)
    |> Listing.changeset(params, user.role)
    |> Repo.insert()
  end

  def update(listing, params, address, user) do
    changeset =
      listing
      |> Changeset.change(address_id: address.id)
      |> Listing.changeset(params, user.role)

    case Repo.update(changeset) do
      {:ok, listing} -> {:ok, listing, changeset}
      error -> error
    end
  end

  def deactivate(listing) do
    listing
    |> Changeset.change(is_active: false)
    |> Repo.update()
  end

  def activate(listing) do
    listing
    |> Changeset.change(is_active: true)
    |> Repo.update()
  end

  def per_user(user) do
    Listing
    |> Queries.per_user(user.id)
    |> Queries.preload_relations()
    |> Repo.all()
  end

  defp do_get(query, id) do
    case Repo.get(query, id) do
      nil -> {:error, :not_found}
      listing -> {:ok, listing}
    end
  end

  def coordinates do
    Listing
    |> Queries.preload_relations([:address])
    |> Repo.all()
  end
end
