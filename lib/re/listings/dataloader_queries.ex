defmodule Re.Listings.DataloaderQueries do
  @moduledoc """
  Module for grouping listings queries
  """
  import Ecto.Query

  alias Re.Filtering

  def build(query, args) do
    args
    |> Map.get(:pagination, [])
    |> Enum.reduce(query, &attr_queries/2)
    |> active()
    |> filter(args)
  end

  defp attr_queries({:excluded_listing_ids, excluded_listing_ids}, query),
    do: where(query, [l], l.id not in ^excluded_listing_ids)

  defp attr_queries({:page_size, page_size}, query),
    do: limit(query, ^page_size)

  defp attr_queries(_, query), do: query

  defp active(query), do: where(query, [l], l.is_active == true)

  defp filter(query, %{filters: filters}), do: Filtering.apply(query, filters)
  defp filter(query, _), do: query
end
