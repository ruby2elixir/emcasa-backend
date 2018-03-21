defmodule Re.Listings.Queries do
  alias Re.Listing
  alias Re.Images.Queries, as: IQ

  import Ecto.Query

  def active(query \\ Listing), do: where(query, [l], l.is_active == true)

  def order_by(query \\ Listing), do: order_by(query, [l], desc: l.score, asc: l.matterport_code)

  def preload(query \\ Listing), do: preload(query, [:address, images: ^IQ.listing_preload()])
end
