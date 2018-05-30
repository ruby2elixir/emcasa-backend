defmodule Re.Messages.Channels.Queries do
  @moduledoc """
  Module for grouping channel queries
  """
  import Ecto.Query

  alias Re.{
    Messages,
    Messages.Channels.Channel
  }

  @shallow_preload [
    :participant1,
    :participant2,
    :listing,
    messages: Messages.Queries.last_message()
  ]

  def by_participant(query, user_id),
    do: where(query, [c], c.participant1_id == ^user_id or c.participant2_id == ^user_id)

  def preload(query \\ Channel), do: preload(query, ^@shallow_preload)
end
