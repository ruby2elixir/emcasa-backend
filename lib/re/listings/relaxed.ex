defmodule Re.Listings.Relaxed do
  @moduledoc """
  Module to build relaxed queries from filters
  It expands the filters with more/less value than the max/min
  """
  import Ecto.Query

  alias Re.{
    Listing,
    Listings.Filter,
    Listings.Queries,
    Repo
  }

  def get(params) do
    relaxed_filters = Filter.relax(params)

    Listing
    |> Filter.apply(relaxed_filters)
    |> Queries.active()
    |> excluding(params)
    |> Queries.order_by()
    |> Queries.preload()
    |> Repo.paginate(params)
    |> Queries.randomize_within_score()
    |> include_filters(relaxed_filters)
  end

  defp include_filters(result, filters), do: Map.put(result, :filters, filters)

  defp excluding(query, %{"excluded_listing_ids" => excluded_listing_ids}),
    do: from(l in subquery(query), where: l.id not in ^excluded_listing_ids)

  defp excluding(query, _), do: query
end
