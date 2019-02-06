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
    Filtering,
    Listing,
    Listings.Queries,
    Repo
  }

  def get_highlight_listing_ids(params \\ %{}) do
    get_highlights(params)
    |> Enum.map(& &1.id)
  end

  defp get_highlights(params) do
    filters = mount_filters(params)

    Queries.active()
    |> Filtering.apply(filters)
    |> Queries.preload_relations([:address])
    |> Queries.limit(params)
    |> Queries.offset(params)
    |> Repo.all()
    |> order_by_score()
  end

  defp order_by_score(highlights) do
    max_id = get_max_id()

    highlights
    |> Enum.map(&%{listing: &1, score: calculate_highlight_score(&1, max_id)})
    |> Enum.sort(&(&1.score >= &2.score))
    |> Enum.map(& &1.listing)
  end

  defp get_max_id() do
    Queries.active()
    |> Queries.max_id()
    |> Re.Repo.one()
  end

  def calculate_highlight_score(_, 0), do: 0

  def calculate_highlight_score(%{id: listing_id}, max_id) when listing_id > max_id, do: 1

  def calculate_highlight_score(%{id: listing_id}, max_id) do
    listing_id / max_id
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
