defmodule Re.Listings.Highlights do
  @moduledoc """
  Context module for listing highlights
  """

  import Ecto.Query

  alias Re.Listings.Highlights.{
    Zap,
    ZapSuper,
    Vivareal
  }

  alias Re.Repo

  def get_zap_highlights, do: get_highlight_listings(Zap)
  def get_zap_super_highlights, do: get_highlight_listings(ZapSuper)
  def get_vivareal_highlights, do: get_highlight_listings(Vivareal)

  defp get_highlight_listings(schema) do
    schema
    |> preload(:listing)
    |> Repo.all()
    |> Enum.map(&Map.get(&1, :listing))
  end

  def insert_zap_highlight(listing), do: insert_highlight_listing(listing, Zap)
  def insert_zap_super_highlight(listing), do: insert_highlight_listing(listing, ZapSuper)
  def insert_vivareal_highlight(listing), do: insert_highlight_listing(listing, Vivareal)

  defp insert_highlight_listing(listing, schema) do
    schema
    |> Kernel.struct()
    |> schema.changeset(%{listing_id: listing.id})
    |> Repo.insert()
  end

end
