defmodule Re.Listings.Featured do
  @moduledoc """
  Module that contains featured listings queries
  It tries to get from a table of featured listings and falls back to top score listings
  """
  import Ecto.Query

  alias Re.{
    Listings,
    Repo
  }

  def get do
    Listings.Queries.active()
    |> Listings.Queries.order_by()
    |> Listings.Queries.preload_relations()
    |> Repo.all()
    |> Enum.filter(&filter_no_images/1)
    |> Enum.take(4)
  end

  defp filter_no_images(%{images: []}), do: false
  defp filter_no_images(_), do: true
end
