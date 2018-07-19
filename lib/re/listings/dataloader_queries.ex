defmodule Re.Listings.DataloaderQueries do
  @moduledoc """
  Module for grouping listings queries
  """
  import Ecto.Query

  alias Re.Filtering

  def build(query, args) do
    query
    |> where([l], l.is_active == true)
    |> paginate(args)
    |> filter(args)
  end

  defp paginate(query, %{pagination: args}), do: Enum.reduce(args, query, &attr_queries/2)

  defp filter(query, %{filters: args}), do: Filtering.apply(query, args)

  defp attr_queries({:excluded_listing_ids, excluded_listing_ids}, query),
    do: where(query, [l], l.id not in ^excluded_listing_ids)

  defp attr_queries({:page_size, page_size}, query),
    do: limit(query, ^page_size)

  defp attr_queries(_, query), do: query
end
