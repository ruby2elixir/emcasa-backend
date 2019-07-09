defmodule Re.Listings.Filters do
  @moduledoc """
  Module for grouping filter queries
  """
  use Ecto.Schema

  import Ecto.{
    Query,
    Changeset
  }

  alias Re.Listings.Filters.Relax

  schema "listings_filter" do
    field :max_price, :integer
    field :min_price, :integer
    field :max_rooms, :integer
    field :min_rooms, :integer
    field :max_suites, :integer
    field :min_suites, :integer
    field :max_bathrooms, :integer
    field :min_bathrooms, :integer
    field :min_area, :integer
    field :max_area, :integer
    field :neighborhoods, {:array, :string}
    field :types, {:array, :string}
    field :max_lat, :float
    field :min_lat, :float
    field :max_lng, :float
    field :min_lng, :float
    field :neighborhoods_slugs, {:array, :string}
    field :max_garage_spots, :integer
    field :min_garage_spots, :integer
    field :garage_types, {:array, :string}
    field :cities, {:array, :string}
    field :cities_slug, {:array, :string}
    field :states_slug, {:array, :string}
    field :exportable, :boolean
    field :tags_slug, {:array, :string}
    field :tags_uuid, {:array, :string}
    field :statuses, {:array, :string}
    field :min_floor_count, :integer
    field :max_floor_count, :integer
    field :min_unit_per_floor, :integer
    field :max_unit_per_floor, :integer
    field :orientations, {:array, :string}
    field :sun_periods, {:array, :string}
    field :min_age, :integer
    field :max_age, :integer
    field :min_price_per_area, :float
    field :max_price_per_area, :float
    field :min_maintenance_fee, :float
    field :max_maintenance_fee, :float
    field :is_release, :boolean
    field :exclude_similar_for_primary_market, :boolean
  end

  @filters ~w(max_price min_price max_rooms min_rooms max_suites min_suites min_area max_area
              neighborhoods types max_lat min_lat max_lng min_lng neighborhoods_slugs
              max_garage_spots min_garage_spots garage_types cities cities_slug states_slug
              exportable tags_slug tags_uuid statuses min_floor_count max_floor_count
              min_unit_per_floor max_unit_per_floor orientations sun_periods min_age max_age
              min_price_per_area max_price_per_area min_maintenance_fee max_maintenance_fee
              max_bathrooms min_bathrooms is_release exclude_similar_for_primary_market)a

  def changeset(struct, params \\ %{}), do: cast(struct, params, @filters)

  def apply(query, params) do
    params
    |> cast()
    |> build_query(query)
  end

  def cast(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Map.get(:changes)
  end

  def relax(params) do
    params
    |> cast()
    |> Relax.apply()
  end

  defp build_query(params, query), do: Enum.reduce(params, query, &attr_filter/2)

  defp attr_filter({:max_price, max_price}, query) do
    from(l in query, where: l.price <= ^max_price)
  end

  defp attr_filter({:min_price, min_price}, query) do
    from(l in query, where: l.price >= ^min_price)
  end

  defp attr_filter({:max_rooms, max_rooms}, query) do
    from(l in query, where: l.rooms <= ^max_rooms)
  end

  defp attr_filter({:min_rooms, min_rooms}, query) do
    from(l in query, where: l.rooms >= ^min_rooms)
  end

  defp attr_filter({:max_suites, max_suites}, query) do
    from(l in query, where: l.suites <= ^max_suites)
  end

  defp attr_filter({:min_suites, min_suites}, query) do
    from(l in query, where: l.suites >= ^min_suites)
  end

  defp attr_filter({:max_bathrooms, max_bathrooms}, query) do
    from(l in query, where: l.bathrooms <= ^max_bathrooms)
  end

  defp attr_filter({:min_bathrooms, min_bathrooms}, query) do
    from(l in query, where: l.bathrooms >= ^min_bathrooms)
  end

  defp attr_filter({:min_area, min_area}, query) do
    from(l in query, where: l.area >= ^min_area)
  end

  defp attr_filter({:max_area, max_area}, query) do
    from(l in query, where: l.area <= ^max_area)
  end

  defp attr_filter({:neighborhoods, []}, query), do: query

  defp attr_filter({:statuses, []}, query), do: query

  defp attr_filter({:statuses, statuses}, query) do
    from(l in query, where: l.status in ^statuses)
  end

  defp attr_filter({:neighborhoods, neighborhoods}, query) do
    from(
      l in query,
      join: ad in assoc(l, :address),
      on: ad.id == l.address_id,
      where: ad.neighborhood in ^neighborhoods
    )
  end

  defp attr_filter({:neighborhoods_slugs, []}, query), do: query

  defp attr_filter({:neighborhoods_slugs, neighborhood_slugs}, query) do
    from(
      l in query,
      join: ad in assoc(l, :address),
      on: ad.id == l.address_id,
      where: ad.neighborhood_slug in ^neighborhood_slugs
    )
  end

  defp attr_filter({:types, []}, query), do: query

  defp attr_filter({:types, types}, query) do
    from(l in query, where: l.type in ^types)
  end

  defp attr_filter({:max_lat, max_lat}, query) do
    from(
      l in query,
      join: ad in assoc(l, :address),
      where: ad.lat <= ^max_lat
    )
  end

  defp attr_filter({:min_lat, min_lat}, query) do
    from(
      l in query,
      join: ad in assoc(l, :address),
      where: ad.lat >= ^min_lat
    )
  end

  defp attr_filter({:max_lng, max_lng}, query) do
    from(
      l in query,
      join: ad in assoc(l, :address),
      where: ad.lng <= ^max_lng
    )
  end

  defp attr_filter({:min_lng, min_lng}, query) do
    from(
      l in query,
      join: ad in assoc(l, :address),
      where: ad.lng >= ^min_lng
    )
  end

  defp attr_filter({:max_garage_spots, max_garage_spots}, query) do
    from(l in query, where: l.garage_spots <= ^max_garage_spots)
  end

  defp attr_filter({:min_garage_spots, min_garage_spots}, query) do
    from(l in query, where: l.garage_spots >= ^min_garage_spots)
  end

  defp attr_filter({:garage_types, []}, query), do: query

  defp attr_filter({:garage_types, garage_types}, query) do
    from(l in query, where: l.garage_type in ^garage_types)
  end

  defp attr_filter({:cities, []}, query), do: query

  defp attr_filter({:cities, cities}, query) do
    from(
      l in query,
      join: ad in assoc(l, :address),
      on: ad.id == l.address_id,
      where: ad.city in ^cities
    )
  end

  defp attr_filter({:cities_slug, []}, query), do: query

  defp attr_filter({:cities_slug, cities_slug}, query) do
    from(
      l in query,
      join: ad in assoc(l, :address),
      on: ad.id == l.address_id,
      where: ad.city_slug in ^cities_slug
    )
  end

  defp attr_filter({:states_slug, []}, query), do: query

  defp attr_filter({:states_slug, states_slug}, query) do
    from(
      l in query,
      join: ad in assoc(l, :address),
      on: ad.id == l.address_id,
      where: ad.state_slug in ^states_slug
    )
  end

  defp attr_filter({:exportable, exportable}, query) do
    from(l in query, where: l.is_exportable == ^exportable)
  end

  defp attr_filter({:tags_slug, []}, query), do: query

  defp attr_filter({:tags_slug, slugs}, query) do
    from(
      l in query,
      join: t in assoc(l, :tags),
      where: t.name_slug in ^slugs,
      distinct: l.id
    )
  end

  defp attr_filter({:tags_uuid, []}, query), do: query

  defp attr_filter({:tags_uuid, uuids}, query) do
    from(
      l in query,
      join: t in assoc(l, :tags),
      where: t.uuid in ^uuids,
      distinct: l.id
    )
  end

  defp attr_filter({:min_floor_count, floor_count}, query) do
    from(
      l in query,
      where: l.floor_count >= ^floor_count
    )
  end

  defp attr_filter({:max_floor_count, floor_count}, query) do
    from(
      l in query,
      where: l.floor_count <= ^floor_count
    )
  end

  defp attr_filter({:min_unit_per_floor, unit_per_floor}, query) do
    from(
      l in query,
      where: l.unit_per_floor >= ^unit_per_floor
    )
  end

  defp attr_filter({:max_unit_per_floor, unit_per_floor}, query) do
    from(
      l in query,
      where: l.unit_per_floor <= ^unit_per_floor
    )
  end

  defp attr_filter({:orientations, []}, query), do: query

  defp attr_filter({:orientations, orientations}, query) do
    from(
      l in query,
      where: l.orientation in ^orientations
    )
  end

  defp attr_filter({:sun_periods, []}, query), do: query

  defp attr_filter({:sun_periods, sun_periods}, query) do
    from(
      l in query,
      where: l.sun_period in ^sun_periods
    )
  end

  defp attr_filter({:min_age, age}, query) do
    from(
      l in query,
      where: l.construction_year <= ^age_to_year(age)
    )
  end

  defp attr_filter({:max_age, age}, query) do
    from(
      l in query,
      where: l.construction_year >= ^age_to_year(age)
    )
  end

  defp attr_filter({:min_price_per_area, price_per_area}, query) do
    from(
      l in query,
      where: l.price_per_area >= ^price_per_area
    )
  end

  defp attr_filter({:max_price_per_area, price_per_area}, query) do
    from(
      l in query,
      where: l.price_per_area <= ^price_per_area
    )
  end

  defp attr_filter({:min_maintenance_fee, maintenance_fee}, query) do
    from(
      l in query,
      where: l.maintenance_fee >= ^maintenance_fee
    )
  end

  defp attr_filter({:max_maintenance_fee, maintenance_fee}, query) do
    from(
      l in query,
      where: l.maintenance_fee <= ^maintenance_fee
    )
  end

  defp attr_filter({:is_release, is_release}, query) do
    from(
      l in query,
      where: l.is_release == ^is_release
    )
  end

  defp attr_filter({:exclude_similar_for_primary_market, true}, query) do
    from(
      l in query,
      distinct: coalesce(l.development_uuid, l.uuid),
      where: not (l.is_release == true and l.is_exportable == false)
    )
  end

  defp attr_filter(_, query), do: query

  defp age_to_year(age) do
    today = Date.utc_today()
    today.year - age
  end
end
