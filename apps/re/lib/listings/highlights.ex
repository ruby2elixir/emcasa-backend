defmodule Re.Listings.Highlights do
  @moduledoc """
  Context module for listing highlights
  """

  import Ecto.Query

  alias Re.{
    Listing,
    Repo
  }

  def get_zap_highlights, do: get_highlight_listings(:zap_highlight)
  def get_zap_super_highlights, do: get_highlight_listings(:zap_super_highlight)
  def get_vivareal_highlights, do: get_highlight_listings(:vivareal_highlight)

  defp get_highlight_listings(attribute) do
    Listing
    |> where_attribute(attribute)
    |> Repo.all()
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
