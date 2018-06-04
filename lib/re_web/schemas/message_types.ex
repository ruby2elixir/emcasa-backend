defmodule ReWeb.Schema.MessageTypes do
  @moduledoc """
  GraphQL types for messages
  """
  use Absinthe.Schema.Notation

  alias Re.{
    Listing,
    User
  }

  object :message do
    field :id, :id
    field :message, :string
    field :read, :boolean
    field :notified, :boolean
    field :inserted_at, :datetime

    field :sender, :user do
      resolve fn message, _, _ ->
        batch(
          {ReWeb.Schema.Helpers, :by_id, User},
          message.sender_id,
          &{:ok, Map.get(&1, message.sender_id)}
        )
      end
    end

    field :receiver, :user do
      resolve fn message, _, _ ->
        batch(
          {ReWeb.Schema.Helpers, :by_id, User},
          message.receiver_id,
          &{:ok, Map.get(&1, message.receiver_id)}
        )
      end
    end

    field :listing, :listing do
      resolve fn message, _, _ ->
        batch(
          {ReWeb.Schema.Helpers, :by_id, Listing},
          message.listing_id,
          &{:ok, Map.get(&1, message.listing_id)}
        )
      end
    end
  end

  object :user_messages do
    field :user, :user
    field :messages, list_of(:message)
  end

  object :channel do
    field :id, :id

    field :participant1, :user do
      resolve fn channel, _, _ ->
        batch(
          {ReWeb.Schema.Helpers, :by_id, User},
          channel.participant1_id,
          &{:ok, Map.get(&1, channel.participant1_id)}
        )
      end
    end

    field :participant2, :user do
      resolve fn channel, _, _ ->
        batch(
          {ReWeb.Schema.Helpers, :by_id, User},
          channel.participant2_id,
          &{:ok, Map.get(&1, channel.participant2_id)}
        )
      end
    end

    field :listing, :listing do
      resolve fn channel, _, _ ->
        batch(
          {ReWeb.Schema.Helpers, :by_id, Listing},
          channel.listing_id,
          &{:ok, Map.get(&1, channel.listing_id)}
        )
      end
    end

    field :messages, list_of(:message)
  end

  scalar :datetime, name: "DateTime" do
    serialize(&NaiveDateTime.to_iso8601/1)
    parse(&parse_datetime/1)
  end

  @spec parse_datetime(Absinthe.Blueprint.Input.String.t()) :: {:ok, DateTime.t()} | :error
  @spec parse_datetime(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}
  defp parse_datetime(%Absinthe.Blueprint.Input.String{value: value}) do
    case NaiveDateTime.from_iso8601(value) do
      {:ok, datetime} -> {:ok, datetime}
      _error -> :error
    end
  end

  defp parse_datetime(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp parse_datetime(_) do
    :error
  end
end
