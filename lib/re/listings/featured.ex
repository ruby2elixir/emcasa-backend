defmodule Re.Listings.Featured do
  @moduledoc """
  Module that contains featured listings queries
  It tries to get from a table of featured listings and falls back to top score listings
  """
  import Ecto.Query

  alias Re.{
    Listing,
    Listings,
    Listings.FeaturedListing,
    Repo
  }

  def get do
    FeaturedListing
    |> order_by([fl], asc: fl.position)
    |> preload([:listing, listing: [:address, images: ^Listings.order_by_position()]])
    |> Repo.all()
    |> Enum.map(&Map.get(&1, :listing))
    |> check_if_exists()
  end

  @top_4_listings_query from(l in Listing, where: l.is_active == true, order_by: [desc: l.score])

  defp check_if_exists([_, _, _, _] = featured), do: featured

  defp check_if_exists(_) do
    @top_4_listings_query
    |> preload([:address, images: ^Listings.order_by_position()])
    |> Repo.all()
  end
end
