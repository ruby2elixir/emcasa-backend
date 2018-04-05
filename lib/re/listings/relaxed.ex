defmodule Re.Listings.Relaxed do
  @moduledoc """
  Module to build relaxed queries from filters
  It expands the filters with more/less value than the max/min
  """
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
    |> Queries.excluding(params)
    |> Queries.order_by()
    |> Queries.limit(params)
    |> Queries.preload()
    |> Repo.all()
    |> include_filters(relaxed_filters)
  end

  defp include_filters(listings, filters), do: %{listings: listings, filters: filters}
end
