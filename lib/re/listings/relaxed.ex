defmodule Re.Listings.Relaxed do
  @moduledoc """
  Module to build relaxed queries from filters
  It expands the filters with more/less value than the max/min
  """
  alias Re.{
    Listing,
    Listings,
    Listings.Filter,
    Listings.Queries,
    Repo
  }

  def get(params) do
    relaxed_filters = Filter.relax(params)

    query =
      Listing
      |> Filter.apply(relaxed_filters)
      |> Queries.active()
      |> Queries.excluding(params)
      |> Queries.order_by()
      |> Queries.limit(params)
      |> Queries.preload()

    listings = Repo.all(query)

    %{
      listings: listings,
      filters: relaxed_filters,
      remaining_count: Listings.remaining_count(query, params)
    }
  end
end
