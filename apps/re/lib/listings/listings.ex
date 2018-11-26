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
    Listings.PriceHistory,
    Listings.Queries,
    Repo,
    User
  }

  alias Ecto.{
    Changeset,
    Multi
  }

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(query, params), do: DataloaderQueries.build(query, params)

  def index, do: Repo.all(Listing)

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
    images: Images.Queries.listing_preload()
  ]

  defp build_query(params) do
    Queries.active()
    |> Queries.excluding(params)
    |> Queries.exclude_blacklisted(params)
    |> Queries.order_by(params)
    |> Queries.limit(params)
    |> Queries.preload_relations(@partial_preload)
    |> Filtering.apply(params)
  end

  def get(id), do: do_get(Listing, id)

  def get_preloaded(id), do: do_get(Queries.preload_relations(), id)

  def insert(params, address, user) do
    with {:ok, user} <- validate_phone_number(params, user),
         do: do_insert(params, address, user)
  end

  defp do_insert(params, address, user) do
    %Listing{}
    |> Changeset.change(address_id: address.id)
    |> Changeset.change(user_id: user.id)
    |> Listing.changeset(params, user.role)
    |> Repo.insert()
  end

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

  def update(listing, params, address, user) do
    listing_changeset = update_listing(listing, params, address, user)

    Multi.new()
    |> Multi.update(:listing, listing_changeset)
    |> save_old_price(listing_changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{listing: listing}} -> {:ok, listing, listing_changeset}
      error -> error
    end
  end

  defp update_listing(listing, params, address, user) do
    listing
    |> Changeset.change(address_id: address.id)
    |> Listing.changeset(params, user.role)
    |> deactivate_if_not_admin(user)
  end

  defp save_old_price(multi, %{changes: %{price: _}, data: %{id: id, price: old_price}}) do
    changeset = PriceHistory.changeset(%PriceHistory{}, %{price: old_price, listing_id: id})

    Multi.insert(multi, :price_history, changeset)
  end

  defp save_old_price(multi, _), do: multi

  defp deactivate_if_not_admin(changeset, %{role: "user"}),
    do: Changeset.change(changeset, status: "inactive")

  defp deactivate_if_not_admin(changeset, %{role: "admin"}), do: changeset

  def deactivate(listing) do
    listing
    |> Changeset.change(status: "inactive")
    |> Repo.update()
  end

  def activate(listing) do
    listing
    |> Changeset.change(status: "active")
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

  @full_preload [
    :address,
    :listings_visualisations,
    :tour_visualisations,
    :in_person_visits,
    :listings_favorites,
    :interests,
    images: Images.Queries.listing_preload()
  ]

  def with_stats do
    Queries.active()
    |> Queries.order_by()
    |> Queries.preload_relations(@full_preload)
    |> Repo.all()
  end
end
