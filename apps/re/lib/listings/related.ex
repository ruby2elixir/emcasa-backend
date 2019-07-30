defmodule Re.Listings.Related do
  @moduledoc """
  Module that contains related listings queries based on a listing
  It takes apart a few common attributes and attempts queries
  """

  alias Re.{
    Listing,
    Listings,
    Listings.Queries,
    Repo
  }

  def get(uuid, params \\ %{}) do
    case Re.AlikeTeller.get(uuid) do
      {:ok, uuids} -> build_listing_index(uuids, params)
      {:error, :not_found} -> {:ok, []}
    end
  end

  defp build_listing_index(uuids, params) do
    query =
      Listing
      |> Queries.with_uuids(uuids)
      |> Queries.active()
      |> Queries.limit(params)
      |> Queries.offset(params)

    %{
      listings: Repo.all(query),
      remaining_count: Listings.remaining_count(query, params)
    }
  end
end
