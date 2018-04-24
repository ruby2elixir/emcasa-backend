defmodule ReWeb.Search.Store do
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
    |> Queries.preload()
    |> Queries.active()
    |> Repo.all()
  end

  def load(_schema, _offset, _limit) do
    []
  end
end
