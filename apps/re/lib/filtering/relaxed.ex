defmodule Re.Filtering.Relaxed do
  @moduledoc """
  Module to build relaxed queries from filters
  It expands the filters with more/less value than the max/min
  """
  alias Re.{
    Images,
    Listing,
    Listings,
    Filtering,
    Listings.Queries,
    Repo
  }

  @relations [
    :address,
    images: Images.Queries.listing_preload()
  ]

  def get(params) do
    relaxed_filters = Filtering.relax(params)

    query =
      Listing
      |> Filtering.apply(relaxed_filters)
      |> Queries.active()
      |> Queries.excluding(params)
      |> Queries.order_by()
      |> Queries.limit(params)
      |> Queries.preload_relations(@relations)

    listings = Repo.all(query)

    %{
      listings: listings,
      filters: relaxed_filters,
      remaining_count: Listings.remaining_count(query, params)
    }
  end
end
