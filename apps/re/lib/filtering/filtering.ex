defmodule Re.Filtering do
  @moduledoc """
  Module for grouping filter queries
  """
  use Ecto.Schema

  import Ecto.{
    Query,
    Changeset
  }

  alias Re.Filtering.Relax

  schema "listings_filter" do
    field :max_price, :integer
    field :min_price, :integer
    field :max_rooms, :integer
    field :min_rooms, :integer
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
  end

  @filters ~w(max_price min_price max_rooms min_rooms min_area max_area neighborhoods types
              max_lat min_lat max_lng min_lng neighborhoods_slugs max_garage_spots
              min_garage_spots garage_types)a

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

  defp attr_filter({:min_area, min_area}, query) do
    from(l in query, where: l.area >= ^min_area)
  end

  defp attr_filter({:max_area, max_area}, query) do
    from(l in query, where: l.area <= ^max_area)
  end

  defp attr_filter({:neighborhoods, []}, query), do: query

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

  defp attr_filter(_, query), do: query
end
