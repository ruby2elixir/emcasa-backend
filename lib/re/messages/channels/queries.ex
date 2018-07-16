defmodule Re.Messages.Channels.Queries do
  @moduledoc """
  Module for grouping channel queries
  """
  import Ecto.Query

  alias Re.{
    Messages,
    Messages.Channels.Channel
  }

  @full_preload [
    :participant1,
    :participant2,
    :listing,
    messages: Messages.Queries.order_by_insertion()
  ]

  def build_query(query, params), do: Enum.reduce(params, query, &do_build_query/2)

  def preload(query \\ Channel), do: preload(query, ^@full_preload)

  defp do_build_query({:other_participant_id, user_id}, query),
    do: where(query, [c], c.participant1_id == ^user_id or c.participant2_id == ^user_id)

  defp do_build_query({:listing_id, listing_id}, query),
    do: where(query, [c], c.listing_id == ^listing_id)

  defp do_build_query({:current_user_id, user_id}, query),
    do: where(query, [c], c.participant1_id == ^user_id or c.participant2_id == ^user_id)

  defp do_build_query(_, query), do: query
end
