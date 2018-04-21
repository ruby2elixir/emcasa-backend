defmodule Re.Messages do
  @moduledoc """
  Context module for messages
  """
  @behaviour Bodyguard.Policy

  alias Re.{
    Message,
    Repo
  }

  alias __MODULE__.Queries

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def send(sender, params) do
    params = Map.merge(params, %{sender_id: sender.id})

    %Message{}
    |> Message.changeset(params)
    |> Repo.insert()
  end

  def get(user, params) do
    Message
    |> by_listing(params)
    |> by_user(user)
    |> Repo.all()
  end

  defp by_listing(query, %{listing_id: listing_id}), do: Queries.by_listing(query, listing_id)
  defp by_listing(query, _params), do: query

  defp by_user(query, user) do
    query
    |> Queries.belongs_to_user(user.id)
    |> Queries.order_by_insertion()
  end
end
