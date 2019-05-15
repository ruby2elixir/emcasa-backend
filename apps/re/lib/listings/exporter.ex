defmodule Re.Listings.Exporter do
  @moduledoc """
  Module for mount and execute listings exports related queries
  """

  alias Re.{
    Images,
    Filtering,
    Listings.Queries,
    Repo,
    Tags
  }

  @preload [
    :address,
    :development,
    tags: Tags.Queries.listing_preload(),
    images: Images.Queries.listing_preload()
  ]

  def exportable(filters, _params) do
    filters = Map.put(filters, :exportable, true)

    Queries.active()
    |> Filtering.apply(filters)
    |> Queries.preload_relations(@preload)
    |> Queries.order_by_id()
    |> Repo.all()
  end
end
