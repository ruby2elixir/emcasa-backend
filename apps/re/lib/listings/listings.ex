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
    Tags,
    User
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
    with {:ok, _} <- validate_phone_number(params, Keyword.get(opts, :user)),
         opts_map <- Enum.into(opts, %{}),
         do: do_insert(params, opts_map)
  end

  defp do_insert(params, %{development: development} = opts) do
    %Listing{}
    |> changeset_for_opts(opts)
    |> copy_infrastructure(development)
    |> Listing.development_changeset(params)
    |> Repo.insert()
    |> publish_if_admin(opts.user.role)
  end

  defp do_insert(params, opts) do
    %Listing{}
    |> changeset_for_opts(opts)
    |> Listing.changeset(params, opts.user.role)
    |> Repo.insert()
    |> publish_if_admin(opts.user.role)
  end

  defp copy_infrastructure(changeset, development) do
    Changeset.change(changeset, %{
      floor_count: development.floor_count,
      unit_per_floor: development.units_per_floor,
      elevators: development.elevators
    })
  end

  defp publish_if_admin(result, "user"), do: PubSub.publish_new(result, "new_listing")

  defp publish_if_admin(result, _), do: result

  defp validate_phone_number(params, user) do
    phone = params["phone"] || params[:phone] || user.phone

    case {phone, user} do
      {nil, %{role: "admin"}} -> {:ok, user}
      {nil, _user} -> {:error, :phone_number_required}
      {phone, user} -> save_phone_number(user, phone)
    end
  end

  defp save_phone_number(user, phone) do
    user
    |> User.update_changeset(%{phone: phone})
    |> Repo.update()
  end

  def update(listing, params, opts \\ []) do
    do_update(listing, params, Enum.into(opts, %{}))
  end

  def do_update(listing, params, %{development: _} = opts) do
    changeset =
      listing
      |> changeset_for_opts(opts)
      |> Listing.development_changeset(params)

    changeset
    |> Repo.update()
    |> PubSub.publish_update(changeset, "update_listing", %{user: opts.user})
  end

  def do_update(listing, params, %{user: user} = opts) do
    changeset =
      listing
      |> changeset_for_opts(opts)
      |> Listing.changeset(params, user.role)
      |> deactivate_if_not_admin(user)

    changeset
    |> Repo.update()
    |> PubSub.publish_update(changeset, "update_listing", %{user: user})
  end

  defp changeset_for_opts(%{user_id: user_id} = listing, opts) do
    Enum.reduce(opts, Changeset.change(listing), fn
      {:development, development}, changeset ->
        Changeset.change(changeset, %{development_uuid: development.uuid, is_exportable: false})

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

  def update_from_unit_params(listing, params) do
    changeset =
      listing
      |> Changeset.change(params)

    changeset
    |> Repo.update()
    |> PubSub.publish_update(changeset, "update_listing")
  end

  defp deactivate_if_not_admin(changeset, %{role: "user"}),
    do: Changeset.change(changeset, status: "inactive")

  defp deactivate_if_not_admin(changeset, %{role: "admin"}), do: changeset

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

  def coordinates do
    Listing
    |> Queries.preload_relations([:address])
    |> Repo.all()
  end

  @full_preload [
    :address,
    :listings_visualisations,
    :tour_visualisations,
    :in_person_visits,
    :listings_favorites,
    :interests,
    :tags,
    images: Images.Queries.listing_preload()
  ]

  def with_stats do
    Queries.active()
    |> Queries.order_by()
    |> Queries.preload_relations(@full_preload)
    |> Repo.all()
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
