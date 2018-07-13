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

  def by_participant(query, user_id),
    do: where(query, [c], c.participant1_id == ^user_id or c.participant2_id == ^user_id)

  def preload(query \\ Channel), do: preload(query, ^@full_preload)

  def by_params(query, params), do: Enum.reduce(params, query, &build_query/2)

  defp build_query({:other_participant_id, other_participant_id}, query),
    do: by_participant(query, other_participant_id)

  defp build_query({:listing_id, listing_id}, query),
    do: where(query, [c], c.listing_id == ^listing_id)

  defp build_query(_, query), do: query
end
