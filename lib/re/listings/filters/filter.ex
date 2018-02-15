defmodule Re.Listings.Filter do
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
    field(:max_price, :integer)
    field(:min_price, :integer)
    field(:rooms, :integer)
    field(:min_area, :integer)
    field(:max_area, :integer)
    field(:neighborhoods, {:array, :string})
    field(:types, {:array, :string})
    field(:max_lat, :float)
    field(:min_lat, :float)
    field(:max_lng, :float)
    field(:min_lng, :float)
  end

  @filters ~w(max_price min_price rooms min_area max_area neighborhoods types
              max_lat min_lat max_lng min_lng)a

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

  def relax(query, params, types) do
    params
    |> cast()
    |> Relax.apply(types)
    |> build_query(query)
  end

  defp build_query(params, query), do: Enum.reduce(params, query, &attr_filter/2)

  defp attr_filter({:max_price, max_price}, query) do
    from(l in query, where: l.price <= ^max_price)
  end

  defp attr_filter({:min_price, min_price}, query) do
    from(l in query, where: l.price >= ^min_price)
  end

  defp attr_filter({:rooms, rooms}, query) do
    from(l in query, where: l.rooms == ^rooms)
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
      where: ad.neighborhood in ^neighborhoods and ad.id == l.address_id
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

  defp attr_filter(_, query), do: query
end
