defmodule Re.Listings.Highlights do
  @moduledoc """
  Context module for listing highlights
  """

  @vivareal_highlights_size_sao_paulo Application.get_env(
                                        :re,
                                        :vivareal_highlights_size_sao_paulo,
                                        0
                                      )
  @vivareal_highlights_size_rio_de_janeiro Application.get_env(
                                             :re,
                                             :vivareal_highlights_size_rio_de_janeiro,
                                             0
                                           )

  @sao_paulo_highlight_size Application.get_env(:re, :zap_highlights_size_sao_paulo, 0)
  @rio_de_janeiro_highlight_size Application.get_env(:re, :zap_highlights_size_rio_de_janeiro, 0)

  @sao_paulo_super_highlight_size Application.get_env(
                                    :re,
                                    :zap_super_highlights_size_sao_paulo,
                                    0
                                  )
  @rio_de_janeiro_super_highlight_size Application.get_env(
                                         :re,
                                         :zap_super_highlights_size_rio_de_janeiro,
                                         0
                                       )

  alias Re.{
    Address,
    Filtering,
    Listing,
    Listings.Queries,
    Repo
  }

  import Ecto.Query

  def get_highlight_listing_ids(params \\ %{}) do
    get_highlights(params)
    |> Enum.map(& &1.id)
  end

  defp get_highlights(params) do
    filters = mount_filters(params)

    all_highlights = Queries.active()
    |> Filtering.apply(filters)
    |> Queries.preload_relations([:address])
    |> Repo.all()
    |> order_by_score()
    |> Enum.drop(Map.get(params, :offset, 0))

    if Map.has_key?(params, :page_size) do
       Enum.take(all_highlights, Map.get(params, :page_size, 0))
    else
      all_highlights
    end
  end

  defp order_by_score(highlights) do
    options =
      Map.put(%{}, :max_id, get_max_id())
      |> Map.put(:average_price_by_neighborhood, get_average_price_per_area_by_neighborhood())

    highlights
    |> Enum.map(&%{listing: &1, score: calculate_highlight_score(&1, options)})
    |> Enum.sort(&(&1.score >= &2.score))
    |> Enum.map(& &1.listing)
  end

  defp get_average_price_per_area_by_neighborhood() do
    from(
      l in Listing,
      inner_join: a in Address, on: a.id == l.address_id,
      select: %{
        neighborhood_slug: a.neighborhood_slug,
        average_price_by_neighborhood: fragment("avg(?/?)::float", l.price, l.area)
      },
      where: l.status == "active",
      group_by: a.neighborhood_slug
    )
    |> Re.Repo.all()
    |> Enum.reduce(%{}, fn item, acc -> Map.merge(acc, %{item.neighborhood_slug => item.average_price_by_neighborhood}) end)
  end

  defp get_max_id() do
    Queries.active()
    |> Queries.max_id()
    |> Re.Repo.one()
  end

  def calculate_highlight_score(listing, options) do
    max_id = Map.get(options, :max_id)
    average_price_per_area_by_neighborhood = Map.get(options, :average_price_by_neighborhood)
    calculate_recency_score(listing, max_id) + calculate_price_per_area_score(listing, average_price_per_area_by_neighborhood)
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

  @neighborhoods_slugs ~w(botafogo copacabana flamengo humaita ipanema lagoa laranjeiras leblon perdizes vila-pompeia)

  defp mount_filters(params) do
    Map.get(params, :filters, %{})
    |> Map.merge(%{max_price: 2_000_000})
    |> Map.merge(%{max_rooms: 3})
    |> Map.merge(%{min_garage_spots: 1})
    |> Map.merge(%{neighborhoods_slugs: @neighborhoods_slugs})
  end

  def get_vivareal_highlights_size(city),
    do: get_highlights_size(:vivareal_highlight, city)

  def get_zap_highlights_size(city),
    do: get_highlights_size(:zap_highlight, city)

  def get_zap_super_highlights_size(city),
    do: get_highlights_size(:zap_super_highlight, city)

  defp get_highlights_size(:vivareal_highlight, "sao-paulo"),
    do: @vivareal_highlights_size_sao_paulo

  defp get_highlights_size(:vivareal_highlight, "rio-de-janeiro"),
    do: @vivareal_highlights_size_rio_de_janeiro

  defp get_highlights_size(:zap_highlight, "sao-paulo"), do: @sao_paulo_highlight_size

  defp get_highlights_size(:zap_highlight, "rio-de-janeiro"), do: @rio_de_janeiro_highlight_size

  defp get_highlights_size(:zap_super_highlight, "sao-paulo"),
    do: @sao_paulo_super_highlight_size

  defp get_highlights_size(:zap_super_highlight, "rio-de-janeiro"),
    do: @rio_de_janeiro_super_highlight_size

  defp get_highlights_size(_, _), do: 0
end
