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

  def order_by_id(query \\ Listing), do: order_by(query, [l], asc: l.id)

  def preload(query \\ Listing),
    do: preload(query, [:address, images: ^Images.Queries.listing_preload()])

  def randomize_within_score(%{entries: entries} = result) do
    randomized_entries =
      entries
      |> Enum.chunk_by(& &1.score)
      |> Enum.map(&Enum.shuffle/1)
      |> List.flatten()

    %{result | entries: randomized_entries}
  end
end
