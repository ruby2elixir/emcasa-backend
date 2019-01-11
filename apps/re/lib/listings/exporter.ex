defmodule Re.Listings.Exporter do
  @moduledoc """
  Module for mount and execute listings exports related queries
  """

  alias Re.{
    Images,
    Listings.Queries,
    Repo
  }

  @partial_preload [
    :address,
    images: Images.Queries.listing_preload()
  ]

  def exportable(%{state_slug: state_slug, city_slug: city_slug}, params) do
    Queries.active()
    |> Queries.by_state_slug_and_city_slug(state_slug, city_slug)
    |> Queries.preload_relations(@partial_preload)
    |> Queries.order_by_id()
    |> Queries.offset(params)
    |> Queries.limit(params)
    |> Repo.all()
  end
end
