defmodule Re.Listings.Featured do
  @moduledoc """
  Module that contains featured listings queries
  It tries to get from a table of featured listings and falls back to top score listings
  """
  import Ecto.Query

  alias Re.{
    Listings,
    Listings.FeaturedListing,
    Repo
  }

  def get do
    FeaturedListing
    |> order_by([fl], asc: fl.position)
    |> preload(listing: ^Listings.Queries.preload())
    |> Repo.all()
    |> Enum.map(&Map.get(&1, :listing))
    |> check_if_exists()
    |> Enum.take(4)
  end

  defp check_if_exists([_, _, _, _] = featured), do: featured

  defp check_if_exists(_) do
    Listings.Queries.order_by()
    |> Listings.Queries.preload()
    |> Repo.all()
    |> Enum.filter(&filter_no_images/1)
  end

  defp filter_no_images(%{images: []}), do: false
  defp filter_no_images(_), do: true
end
