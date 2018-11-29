defmodule ReIntegrations.Search.Store do
  @moduledoc """
  Module to implement loading logic for the elasticsearch store
  """
  @behaviour Elasticsearch.Store

  import Ecto.Query

  alias Re.{
    Images,
    Listing,
    Listings.Queries,
    Repo
  }

  @partial_preload [
    :address,
    images: Images.Queries.listing_preload()
  ]

  def load(Listing, offset, limit) do
    Listing
    |> offset(^offset)
    |> limit(^limit)
    |> Queries.preload_relations(@partial_preload)
    |> Queries.active()
    |> Repo.all()
  end

  def load(_schema, _offset, _limit) do
    []
  end
end
