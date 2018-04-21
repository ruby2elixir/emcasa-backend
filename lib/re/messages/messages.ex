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

  def get_listing(listing, user) do
    Message
    |> Queries.by_listing(listing.id)
    |> Queries.belongs_to_user(user.id)
    |> Queries.order_by_insertion()
    |> Repo.all()
  end
end
