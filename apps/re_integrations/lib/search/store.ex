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

  @full_preload [
    :address,
    :listings_visualisations,
    :tour_visualisations,
    :in_person_visits,
    :listings_favorites,
    :interests,
    images: Images.Queries.listing_preload()
  ]

  def load(Listing, offset, limit) do
    Listing
    |> offset(^offset)
    |> limit(^limit)
    |> Queries.preload_relations(@full_preload)
    |> Queries.active()
    |> Repo.all()
  end

  def load(_schema, _offset, _limit) do
    []
  end
end
