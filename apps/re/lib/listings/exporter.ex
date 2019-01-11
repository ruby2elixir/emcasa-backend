defmodule Re.Listings.Exporter do
  @moduledoc """
  Module for mount and execute listings exports related queries
  """

  alias Re.{
    Images,
    Filtering,
    Listings.Queries,
    Repo
  }

  @partial_preload [
    :address,
    images: Images.Queries.listing_preload()
  ]

  def exportable(filters, params) do
    Queries.active()
    |> Filtering.apply(filters)
    |> Queries.preload_relations(@partial_preload)
    |> Queries.order_by_id()
    |> Queries.offset(params)
    |> Queries.limit(params)
    |> Repo.all()
  end
end
