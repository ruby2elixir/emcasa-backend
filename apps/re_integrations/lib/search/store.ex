defmodule ReIntegrations.Search.Store do
  @moduledoc """
  Module to implement loading logic for the elasticsearch store
  """
  @behaviour Elasticsearch.Store

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

  @impl true
  def transaction(fun) do
    {:ok, result} = Repo.transaction(fun, timeout: :infinity)
    result
  end

  @impl true
  def stream(Listing) do
    Listing
    |> Queries.preload_relations(@partial_preload)
    |> Queries.active()
    |> Repo.all()
  end
end
