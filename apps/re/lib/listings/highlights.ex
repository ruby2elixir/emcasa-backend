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

  import Ecto.Query

  alias Re.{
    Filtering,
    Listing,
    Listings.Queries,
    Repo
  }

  def get_highlight_listing_ids(query, params \\ %{}) do
    get_highlights(query, params)
    |> Enum.map(& &1.id)
  end

  defp get_highlights(query, params) do
    order = %{order_by: [%{field: :updated_at, type: :desc}]}

    query
    |> Queries.order_by(order)
    |> Queries.limit(params)
    |> Queries.offset(params)
    |> Repo.all()
  end

  def get_vivareal_highlights(params \\ %{}),
    do: get_highlight_listings(:vivareal_highlight, params)

  defp get_highlight_listings(attribute, params) do
    pagination = Map.get(params, :pagination, %{})
    filters = Map.get(params, :filters, %{})

    Listing
    |> where_attribute(attribute)
    |> Queries.order_by(params)
    |> Filtering.apply(filters)
    |> Repo.paginate(pagination)
  end

  defp where_attribute(query, :vivareal_highlight), do: where(query, [l], l.vivareal_highlight)

  def insert_vivareal_highlight(listing), do: highlight_listing(listing, :vivareal_highlight)

  defp highlight_listing(listing, attribute) do
    listing
    |> Listing.changeset(%{attribute => true}, "admin")
    |> Repo.update()
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
