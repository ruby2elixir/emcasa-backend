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

  def order_by_score(query \\ Listing), do: order_by(query, [l], desc: l.score)

  def randomize(query \\ Listing), do: order_by(query, [_], fragment("RANDOM()"))

  def order_by_matterport_code(query \\ Listing), do: order_by(query, [l], asc: l.matterport_code)

  def order_by_id(query \\ Listing), do: order_by(query, [l], asc: l.id)

  def preload(query \\ Listing),
    do: preload(query, [:address, images: ^Images.Queries.listing_preload()])
end
