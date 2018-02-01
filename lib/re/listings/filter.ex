defmodule Re.Listings.Filter do
  @moduledoc """
  Module for grouping filter queries
  """
  use Ecto.Schema

  import Ecto.{
    Query,
    Changeset
  }

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
    filters =
      %__MODULE__{}
      |> changeset(params)
      |> Map.get(:changes)

    query
    |> max_price_filter(filters)
    |> min_price_filter(filters)
    |> rooms_filter(filters)
    |> min_area_filter(filters)
    |> max_area_filter(filters)
    |> neighborhoods_filter(filters)
    |> types_filter(filters)
    |> max_lat_filter(filters)
    |> min_lat_filter(filters)
    |> max_lng_filter(filters)
    |> min_lng_filter(filters)
  end

  defp max_price_filter(query, %{max_price: max_price}) do
    from(l in query, where: l.price <= ^max_price)
  end

  defp max_price_filter(query, _), do: query

  defp min_price_filter(query, %{min_price: min_price}) do
    from(l in query, where: l.price >= ^min_price)
  end

  defp min_price_filter(query, _), do: query

  defp rooms_filter(query, %{rooms: rooms}) do
    from(l in query, where: l.rooms == ^rooms)
  end

  defp rooms_filter(query, _), do: query

  defp min_area_filter(query, %{min_area: min_area}) do
    from(l in query, where: l.area >= ^min_area)
  end

  defp min_area_filter(query, _), do: query

  defp max_area_filter(query, %{max_area: max_area}) do
    from(l in query, where: l.area <= ^max_area)
  end

  defp max_area_filter(query, _), do: query

  defp neighborhoods_filter(query, %{neighborhoods: []}), do: query

  defp neighborhoods_filter(query, %{neighborhoods: neighborhoods}) do
    from(
      l in query,
      join: ad in assoc(l, :address),
      where: ad.neighborhood in ^neighborhoods and ad.id == l.address_id
    )
  end

  defp neighborhoods_filter(query, _), do: query

  defp types_filter(query, %{types: []}), do: query

  defp types_filter(query, %{types: types}) do
    from(l in query, where: l.type in ^types)
  end

  defp types_filter(query, _), do: query

  defp max_lat_filter(query, %{max_lat: max_lat}) do
    from(
      l in query,
      join: ad in assoc(l, :address),
      where: ad.lat <= ^max_lat
    )
  end

  defp max_lat_filter(query, _), do: query

  defp min_lat_filter(query, %{min_lat: min_lat}) do
    from(
      l in query,
      join: ad in assoc(l, :address),
      where: ad.lat >= ^min_lat
    )
  end

  defp min_lat_filter(query, _), do: query

  defp max_lng_filter(query, %{max_lng: max_lng}) do
    from(
      l in query,
      join: ad in assoc(l, :address),
      where: ad.lng <= ^max_lng
    )
  end

  defp max_lng_filter(query, _), do: query

  defp min_lng_filter(query, %{min_lng: min_lng}) do
    from(
      l in query,
      join: ad in assoc(l, :address),
      where: ad.lng >= ^min_lng
    )
  end

  defp min_lng_filter(query, _), do: query
end
