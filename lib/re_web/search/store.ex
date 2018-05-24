defmodule ReWeb.Search.Store do
  @moduledoc """
  Module to implement loading logic for the elasticsearch store
  """
  @behaviour Elasticsearch.Store

  import Ecto.Query

  alias Re.{
    Listing,
    Listings.Queries,
    Repo
  }

  def load(Listing, offset, limit) do
    Listing
    |> offset(^offset)
    |> limit(^limit)
    |> Queries.preload_relations()
    |> Queries.active()
    |> Repo.all()
  end

  def load(_schema, _offset, _limit) do
    []
  end
end
