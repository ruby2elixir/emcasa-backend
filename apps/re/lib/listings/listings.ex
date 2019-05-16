defmodule Re.Listings do
  @moduledoc """
  Context for listings.
  """
  @behaviour Bodyguard.Policy

  alias Re.{
    Listing,
    Filtering,
    Images,
    Listings.DataloaderQueries,
    Listings.Opts,
    Listings.Queries,
    PubSub,
    Repo,
    Tags
  }

  alias Ecto.Changeset

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(query, params), do: DataloaderQueries.build(query, params)

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
    page_size =
      params
      |> Opts.build()
      |> Map.get(:page_size)

    case page_size do
      nil -> 0
      page_size -> zero_if_negative(count - page_size)
    end
  end

  defp zero_if_negative(num) when num > 0, do: num
  defp zero_if_negative(_num), do: 0

  @partial_preload [
    :address,
    :listings_favorites,
    :tags,
    images: Images.Queries.listing_preload()
  ]

  defp build_query(params) do
    Queries.active()
    |> Queries.excluding(params)
    |> Queries.order_by(params)
    |> Queries.limit(params)
    |> Queries.preload_relations(@partial_preload)
    |> Filtering.apply(params)
  end

  def get(id), do: do_get(Listing, id)

  def get_preloaded(id), do: do_get(Queries.preload_relations(), id)

  def get_partial_preloaded(id, preload),
    do: do_get(Queries.preload_relations(Listing, preload), id)

  def insert(params, opts \\ []) do
    %Listing{}
    |> changeset_for_opts(opts)
    |> Listing.changeset(params)
    |> Repo.insert()
  end

  def update(listing, params, opts \\ []) do
    changeset =
      listing
      |> changeset_for_opts(opts)
      |> Listing.changeset(params)

    changeset
    |> Repo.update()
    |> PubSub.publish_update(changeset, "update_listing")
  end

  defp changeset_for_opts(%{user_id: user_id} = listing, opts) do
    Enum.reduce(opts, Changeset.change(listing), fn
      {:address, address}, changeset ->
        Changeset.change(changeset, %{address_id: address.id})

      {:user, user}, changeset when user_id == nil ->
        Changeset.change(changeset, %{user_id: user.id})

      {:user, _}, changeset ->
        changeset

      {:owner_contact, nil}, changeset ->
        changeset

      {:owner_contact, owner_contact}, changeset ->
        Changeset.change(changeset, %{owner_contact_uuid: owner_contact.uuid})
    end)
  end

  def deactivate(listing) do
    changeset = Changeset.change(listing, status: "inactive")

    changeset
    |> Repo.update()
    |> PubSub.publish_update(changeset, "deactivate_listing")
  end

  def activate(listing) do
    changeset = Changeset.change(listing, status: "active")

    changeset
    |> Repo.update()
    |> PubSub.publish_update(changeset, "activate_listing")
  end

  def per_user(user) do
    Listing
    |> Queries.per_user(user.id)
    |> Queries.preload_relations(@partial_preload)
    |> Repo.all()
  end

  defp do_get(query, id) do
    case Repo.get(query, id) do
      nil -> {:error, :not_found}
      listing -> {:ok, listing}
    end
  end

  def upsert_tags(listing, nil), do: {:ok, listing}

  def upsert_tags(listing, tag_uuids) do
    tags = Tags.list_by_uuids(tag_uuids)

    listing
    |> Repo.preload([:tags])
    |> Listing.changeset_update_tags(tags)
    |> Repo.update()
  end
end
