defmodule Re.Listings.Relaxed do
  @moduledoc """
  Module to build relaxed queries from filters
  It expands the filters with more/less value than the max/min
  """
  import Ecto.Query

  alias Re.{
    Listing,
    Listings,
    Listings.Filter,
    Repo
  }

  alias Re.Listings.Queries, as: LQ

  def get(params) do
    relaxed_filters = Filter.relax(params)

    Listing
    |> Filter.apply(relaxed_filters)
    |> LQ.active()
    |> excluding(params)
    |> LQ.order_by()
    |> LQ.preload()
    |> Repo.paginate(params)
    |> include_filters(relaxed_filters)
  end

  defp include_filters(result, filters), do: Map.put(result, :filters, filters)

  defp excluding(query, %{"excluded_listing_ids" => excluded_listing_ids}),
    do: from(l in subquery(query), where: l.id not in ^excluded_listing_ids)

  defp excluding(query, _), do: query
end
