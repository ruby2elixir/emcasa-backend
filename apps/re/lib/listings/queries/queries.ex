defmodule Re.Listings.Queries do
  @moduledoc """
  Module for grouping listing queries
  """

  alias Re.{
    Filtering,
    Images,
    Interests,
    Listing
  }

  import Ecto.Query

  @full_preload [
    :address,
    :listings_visualisations,
    :tour_visualisations,
    :listings_favorites,
    :in_person_visits,
    interests: Interests.Queries.with_type(),
    images: Images.Queries.listing_preload()
  ]

  @orderable_fields ~w(id price property_tax maintenance_fee rooms bathrooms restrooms area garage_spots suites dependencies balconies updated_at)a

  def active(query \\ Listing), do: where(query, [l], l.status == "active")

  def order_by(query, %{order_by: orders}) do
    orders
    |> Enum.reduce(query, &order_by_criterias/2)
    |> order_by()
  end

  def order_by(query, _), do: query

  defp order_by_criterias(%{field: field, type: type}, query) when field in @orderable_fields do
    order_by(query, [l], {^type, ^field})
  end

  defp order_by_criterias(_, query), do: query

  def order_by(query \\ Listing) do
    query
    |> order_by([l], desc: l.score)
    |> order_by([l], fragment("RANDOM()"))
    |> order_by([l], asc: l.matterport_code)
  end

  def order_by_id(query \\ Listing), do: order_by(query, [l], asc: l.id)

  def preload_relations(query \\ Listing, relations \\ @full_preload)

  def preload_relations(query, relations), do: preload(query, ^relations)

  def randomize_within_score(%{entries: entries} = result) do
    randomized_entries =
      entries
      |> Enum.chunk_by(& &1.score)
      |> Enum.map(&Enum.shuffle/1)
      |> List.flatten()

    %{result | entries: randomized_entries}
  end

  def excluding(query, %{"excluded_listing_ids" => excluded_listing_ids}),
    do: from(l in query, where: l.id not in ^excluded_listing_ids)

  def excluding(query, %{excluded_listing_ids: excluded_listing_ids}),
    do: from(l in query, where: l.id not in ^excluded_listing_ids)

  def excluding(query, _), do: query

  def limit(query, %{"page_size" => page_size}), do: from(l in query, limit: ^page_size)

  def limit(query, %{page_size: page_size}), do: from(l in query, limit: ^page_size)

  def limit(query, _), do: query

  def offset(query, %{"offset" => offset}), do: from(l in query, offset: ^offset)

  def offset(query, %{offset: offset}), do: from(l in query, offset: ^offset)

  def offset(query, _), do: query

  def remaining_count(query) do
    query
    |> exclude(:preload)
    |> exclude(:order_by)
    |> exclude(:limit)
    |> count()
  end

  def count(query \\ Listing), do: from(l in query, select: count(l.id))

  def per_user(query \\ Listing, user_id), do: from(l in query, where: l.user_id == ^user_id)

  def by_city(query, listing) do
    from(
      l in query,
      join: a in assoc(l, :address),
      where: ^listing.address.city == a.city
    )
  end

  def highlights(query \\ Listing, filters) do
    active()
    |> Filtering.apply(filters)
    |> preload_relations([:address])
    |> order_by_id()
  end
end
