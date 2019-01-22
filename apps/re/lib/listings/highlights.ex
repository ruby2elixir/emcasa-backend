defmodule Re.Listings.Highlights do
  @moduledoc """
  Context module for listing highlights
  """

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

  def get_zap_highlights(params \\ %{}), do: get_highlight_listings(:zap_highlight, params)

  def get_zap_super_highlights(params \\ %{}),
    do: get_highlight_listings(:zap_super_highlight, params)

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

  defp where_attribute(query, :zap_highlight), do: where(query, [l], l.zap_highlight)
  defp where_attribute(query, :zap_super_highlight), do: where(query, [l], l.zap_super_highlight)
  defp where_attribute(query, :vivareal_highlight), do: where(query, [l], l.vivareal_highlight)

  def insert_zap_highlight(listing), do: highlight_listing(listing, :zap_highlight)
  def insert_zap_super_highlight(listing), do: highlight_listing(listing, :zap_super_highlight)
  def insert_vivareal_highlight(listing), do: highlight_listing(listing, :vivareal_highlight)

  defp highlight_listing(listing, attribute) do
    listing
    |> Listing.changeset(%{attribute => true}, "admin")
    |> Repo.update()
  end
end
