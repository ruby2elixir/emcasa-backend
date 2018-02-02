defmodule Re.Listings.Related do
  import Ecto.Query

  alias Re.{
    Listings,
    Repo
  }

  def related(listing, limit \\ :no_limit) do
    ~w(price address)a
    |> do_related(listing, Listings.active_listings_query())
    |> Enum.reject(fn %{id: id} -> id == listing.id end)
    |> Enum.uniq_by(fn %{id: id} -> id end)
    |> limit_results(limit)
    |> Repo.preload([:address, images: Listings.order_by_position()])
    |> okd()
  end

  defp limit_results(result, :no_limit), do: result
  defp limit_results(result, limit), do: Enum.take(result, limit)

  defp okd(arg), do: {:ok, arg}

  defp do_related([], _, _), do: Listings.featured()

  defp do_related([_attr | rest] = attrs, listing, query) do
    listing
    |> Repo.preload(:address)
    |> Map.take(attrs)
    |> Enum.reduce(query, &build_query(&1, &2))
    |> Repo.all()
    |> Enum.concat(do_related(rest, listing, query))
  end

  defp build_query({:address, address}, query) do
    from(
      l in query,
      join: a in assoc(l, :address),
      where: ^address.neighborhood == a.neighborhood
    )
  end

  defp build_query({:price, price}, query) do
    price_diff = price * 0.25
    floor = trunc(price - price_diff)
    ceiling = trunc(price + price_diff)

    from(l in query, where: l.price >= ^floor and l.price <= ^ceiling)
  end
end
