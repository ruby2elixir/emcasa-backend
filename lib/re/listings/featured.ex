defmodule Re.Listings.Featured do
  @moduledoc """
  Module that contains featured listings queries
  It tries to get from a table of featured listings and falls back to top score listings
  """

  alias Re.{
    Images,
    Listings,
    Repo
  }

  @featured_preload [:address, images: Images.Queries.listing_preload()]

  def get do
    Listings.Queries.active()
    |> Listings.Queries.order_by()
    |> Listings.Queries.preload_relations(@featured_preload)
    |> Repo.all()
    |> Enum.filter(&filter_no_images/1)
    |> Enum.take(4)
  end

  def get_graphql do
    Listings.Queries.active()
    |> Listings.Queries.order_by()
    |> Listings.Queries.preload_relations(images: Images.Queries.listing_preload())
    |> Repo.all()
    |> Enum.filter(&filter_no_images/1)
    |> Enum.take(4)
  end

  defp filter_no_images(%{images: []}), do: false
  defp filter_no_images(_), do: true
end
