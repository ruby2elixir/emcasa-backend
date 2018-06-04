defmodule Re.Messages do
  @moduledoc """
  Context module for messages
  """
  @behaviour Bodyguard.Policy

  alias Re.{
    Messages.Channels,
    Message,
    Repo
  }

  alias __MODULE__.Queries

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def get(user, params) do
    Message
    |> by_listing(params)
    |> by_sender(params)
    |> by_user(user)
    |> Queries.preload_relations([:sender, :receiver])
    |> Repo.all()
  end

  defp by_listing(query, %{listing_id: listing_id}), do: Queries.by_listing(query, listing_id)
  defp by_listing(query, _params), do: query

  defp by_sender(query, %{sender_id: sender_id}), do: Queries.by_sender(query, sender_id)
  defp by_sender(query, _params), do: query

  defp by_user(query, user) do
    query
    |> Queries.belongs_to_user(user.id)
    |> Queries.order_by_insertion()
  end

  def send(sender, params) do
    params =
      params
      |> Map.merge(%{sender_id: sender.id})
      |> set_channel()

    %Message{}
    |> Message.changeset(params)
    |> Repo.insert()
  end

  defp set_channel(params) do
    {:ok, channel} = Channels.find_or_create_channel(params)

    Map.merge(params, %{channel_id: channel.id})
  end
end
