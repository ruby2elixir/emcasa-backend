defmodule Re.Units.Queries do
  @moduledoc """
  Module for grouping unit queries
  """

  alias Re.Unit

  import Ecto.Query

  def by_listing(query \\ Unit, id)

  def by_listing(query, id), do: where(query, [u], u.listing_id == ^id)

  def active(query \\ Unit), do: where(query, [u], u.status == "active")
end
