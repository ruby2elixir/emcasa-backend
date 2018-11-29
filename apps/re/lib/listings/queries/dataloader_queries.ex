defmodule Re.Listings.DataloaderQueries do
  @moduledoc """
  Module for grouping listings queries
  """
  import Ecto.Query

  alias Re.Filtering

  def build(query, args) do
    query
    |> active(args)
    |> paginate(args)
    |> filter(args)
    |> order_by([l], desc: l.score)
  end

  defp active(query, %{has_admin_rights: true}), do: query

  defp active(query, _args), do: where(query, [l], l.status == "active")

  defp paginate(query, %{pagination: args}), do: Enum.reduce(args, query, &attr_queries/2)

  defp paginate(query, _args), do: query

  defp filter(query, %{filters: args}), do: Filtering.apply(query, args)

  defp filter(query, _args), do: query

  defp attr_queries({:excluded_listing_ids, excluded_listing_ids}, query),
    do: where(query, [l], l.id not in ^excluded_listing_ids)

  defp attr_queries({:page_size, page_size}, query),
    do: limit(query, ^page_size)

  defp attr_queries(_, query), do: query
end
