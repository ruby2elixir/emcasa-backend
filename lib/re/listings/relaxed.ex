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

  def get(params) do
    relaxed_filters = Filter.relax(params)

    Listing
    |> Filter.apply(relaxed_filters)
    |> active_listings_query()
    |> excluding(params)
    |> Listings.order_by_listing()
    |> Listings.preload_listing()
    |> Repo.paginate(params)
    |> include_filters(relaxed_filters)
  end

  defp include_filters(result, filters), do: Map.put(result, :filters, filters)

  defp excluding(query, %{"excluded_listing_ids" => excluded_listing_ids}),
    do: from(l in subquery(query), where: l.id not in ^excluded_listing_ids)

  defp active_listings_query(query), do: from(l in subquery(query), where: l.is_active == true)
end
