defmodule Re.Listings.Highlights.Scores do
  alias Re.{
    Filtering,
    Listings.Queries,
    Repo
  }

  def calculate_highlights_scores(listings) do
    options = %{
      max_id: get_max_id(),
      average_price_per_area_by_neighborhood: get_average_price_per_area_by_neighborhood()
    }

    listings
    |> Enum.map(&(%{listing: &1, score: calculate_highlight_score(&1, options)}))
    |> Enum.sort(&(&1.score >= &2.score))
    |> Enum.map(&(&1.listing))
  end

  def calculate_highlight_score(listing, options) do
    max_id = Map.get(options, :max_id)
    average_price_per_area_by_neighborhood = Map.get(options, :average_price_per_area_by_neighborhood)
    calculate_recency_score(listing, max_id) + calculate_price_per_area_score(listing, average_price_per_area_by_neighborhood)
  end

  defp get_max_id() do
    Queries.active()
    |> Queries.max_id()
    |> Repo.one()
  end

  @neighborhoods_slugs ~w(botafogo copacabana flamengo humaita ipanema lagoa laranjeiras leblon perdizes vila-pompeia)
  @highlight_score_filters %{
    max_price: 2_000_000,
    max_rooms: 3,
    min_garage_spots: 1,
    neighborhoods_slugs: @neighborhoods_slugs
  }

  defp get_average_price_per_area_by_neighborhood() do
    Queries.average_price_per_area_by_neighborhood()
    |> Filtering.apply(@highlight_score_filters)
    |> Repo.all()
    |> Enum.reduce(%{}, fn item, acc -> Map.merge(acc, %{item.neighborhood_slug => item.average_price_per_area}) end)
  end

  def calculate_recency_score(_, 0), do: 0
  def calculate_recency_score(%{id: listing_id}, max_id) when listing_id > max_id, do: 1
  def calculate_recency_score(%{id: listing_id}, max_id) do
    listing_id / max_id
  end

  def calculate_price_per_area_score(%{price: 0}, _), do: 0
  def calculate_price_per_area_score(%{area: 0}, _), do: 0
  def calculate_price_per_area_score(%{price: price, area: area, address: address}, average_price_by_neighborhood) do
    price_per_area = price / area
    price_in_neighborhood = Map.get(average_price_by_neighborhood, address.neighborhood_slug, 0.0)
    price_in_neighborhood / price_per_area
  end

  def mount_filters(filters \\ %{}) do
    filters
    |> Map.merge(@highlight_score_filters)
  end
end
