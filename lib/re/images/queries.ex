defmodule Re.Images.Queries do
  @moduledoc """
  Module for grouping images queries
  """

  alias Re.Image

  import Ecto.Query

  def by_listing(query \\ Image, id)

  def by_listing(query, id), do: where(query, [i], i.listing_id == ^id)

  def active(query \\ Image), do: where(query, [i], i.is_active == true)

  def order_by_position(query \\ Image), do: order_by(query, [i], asc: i.position)

  def listing_preload(query \\ Image) do
    query
    |> active()
    |> order_by_position()
  end
end
