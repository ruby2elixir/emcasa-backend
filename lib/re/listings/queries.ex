defmodule Re.Listings.Queries do
  @moduledoc """
  Module for grouping listing queries
  """

  alias Re.{
    Images,
    Listing
  }

  import Ecto.Query

  def active(query \\ Listing), do: where(query, [l], l.is_active == true)

  def order_by(query \\ Listing), do: order_by(query, [l], desc: l.score, asc: l.matterport_code)

  def preload(query \\ Listing), do: preload(query, [:address, images: ^Images.Queries.listing_preload()])

end
