defmodule Re.Listings.Related do
  @moduledoc """
  Module that contains related listings queries based on a listing
  It takes apart a few common attributes and attempts queries
  """
  import Ecto.Query

  alias Re.{
    Listing,
    Listings,
    Listings.Queries,
    Repo
  }

  def get(listing, params \\ %{}) do
    query =
      ~w(price address rooms)a
      |> Enum.reduce(Listing, &build_query(&1, listing, &2))
      |> exclude_current(listing)
      |> Queries.excluding(params)
      |> Queries.active()
      |> Queries.limit(params)
      |> Queries.preload_relations()

    %{
      listings: Repo.all(query),
      remaining_count: Listings.remaining_count(query, params)
    }
  end

  defp exclude_current(query, listing), do: from(l in query, where: ^listing.id != l.id)

  defp build_query(:address, listing, query) do
    from(
      l in query,
      join: a in assoc(l, :address),
      or_where: ^listing.address.neighborhood == a.neighborhood
    )
  end

  defp build_query(:price, listing, query) do
    price_diff = listing.price * 0.25
    floor = trunc(listing.price - price_diff)
    ceiling = trunc(listing.price + price_diff)

    from(l in query, or_where: l.price >= ^floor and l.price <= ^ceiling)
  end

  defp build_query(:rooms, listing, query) do
    rooms_ceiling = listing.rooms + 1
    rooms_floor = listing.rooms - 1

    from(l in query, or_where: l.rooms >= ^rooms_floor and l.rooms <= ^rooms_ceiling)
  end
end
