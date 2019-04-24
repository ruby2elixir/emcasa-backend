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

  def insert(params, address, user, development \\ nil)

  def insert(params, address, user, nil) do
    with {:ok, user} <- validate_phone_number(params, user),
         do: do_insert(params, address, user)
  end

  def insert(params, address, user, development) do
    %Listing{}
    |> Changeset.change(%{
      development_uuid: development.uuid,
      address_id: address.id,
      user_id: user.id,
      is_exportable: false
    })
    |> Listing.development_changeset(params)
    |> Repo.insert()
    |> publish_if_admin(user.role)
  end

  defp do_insert(params, address, user) do
    %Listing{}
    |> Changeset.change(address_id: address.id)
    |> Changeset.change(user_id: user.id)
    |> Listing.changeset(params, user.role)
    |> Repo.insert()
    |> publish_if_admin(user.role)
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

  def update(listing, params, address, user, development \\ nil)

  def update(listing, params, address, user, nil) do
    changeset =
      listing
      |> Changeset.change(address_id: address.id)
      |> Listing.changeset(params, user.role)
      |> deactivate_if_not_admin(user)

    changeset
    |> Repo.update()
    |> PubSub.publish_update(changeset, "update_listing", %{user: user})
  end

  def update(listing, params, address, user, development) do
    changeset =
      listing
      |> Changeset.change(%{
        development_uuid: development.uuid,
        address_id: address.id,
        user_id: user.id,
        is_exportable: false
      })
      |> Listing.development_changeset(params)

    changeset
    |> Repo.update()
    |> PubSub.publish_update(changeset, "update_listing", %{user: user})
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
