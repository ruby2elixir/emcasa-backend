defmodule Re.Listings.Highlights do
  @moduledoc """
  Context module for listing highlights
  """
  @sao_paulo_highlight_size 20
  @rio_de_janeiro_highlight_size 200

  @sao_paulo_super_highlight_size 3
  @rio_de_janeiro_super_highlight_size 5

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

  def highlights_size("sao-paulo"), do: @sao_paulo_highlight_size

  def highlights_size("rio-de-janeiro"), do: @rio_de_janeiro_highlight_size

  def highlights_size(_city_slug), do: 0

  def super_highlights_size("sao-paulo"), do: @sao_paulo_super_highlight_size

  def super_highlights_size("rio-de-janeiro"), do: @rio_de_janeiro_super_highlight_size

  def super_highlights_size(_city_slug), do: 0
end
