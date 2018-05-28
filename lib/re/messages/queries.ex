defmodule Re.Messages.Queries do
  @moduledoc """
  Module for grouping messages queries
  """
  import Ecto.Query

  alias Re.Message

  def order_by_insertion(query \\ Message), do: order_by(query, [m], asc: m.inserted_at)

  def belongs_to_user(query, user_id),
    do: where(query, [m], m.sender_id == ^user_id or m.receiver_id == ^user_id)

  def by_listing(query \\ Message, listing_id), do: where(query, [m], m.listing_id == ^listing_id)

  def by_sender(query \\ Message, sender_id),
    do: where(query, [m], m.sender_id == ^sender_id or m.receiver_id == ^sender_id)
end
