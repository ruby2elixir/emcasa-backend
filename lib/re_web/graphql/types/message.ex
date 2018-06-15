defmodule ReWeb.Types.Message do
  @moduledoc """
  GraphQL types for messages
  """
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias Re.{
    Listing,
    User
  }
  alias ReWeb.Resolvers.Messages, as: MessagesResolver

  object :message do
    field :id, :id
    field :message, :string
    field :read, :boolean
    field :notified, :boolean
    field :inserted_at, :datetime

    field :sender, :user, resolve: dataloader(Re.Accounts)
    field :receiver, :user, resolve: dataloader(Re.Accounts)
    field :listing, :listing, resolve: dataloader(Re.Listings)
  end

  object :user_messages do
    field :user, :user
    field :messages, list_of(:message)
  end

  object :channel do
    field :id, :id

    field :participant1, :user, resolve: dataloader(Re.Accounts)
    field :participant2, :user, resolve: dataloader(Re.Accounts)
    field :listing, :listing, resolve: dataloader(Re.Listings)

    field :unread_count, :integer
    field :last_message, :message
    field :messages, list_of(:message)
  end

  object :message_mutations do
    @desc "Send message"
    field :send_message, type: :message do
      arg :receiver_id, non_null(:id)
      arg :listing_id, non_null(:id)

      arg :message, :string

      resolve &MessagesResolver.send/2
    end
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
