defmodule ReWeb.Types.Message do
  @moduledoc """
  GraphQL types for messages
  """
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias ReWeb.Resolvers.Messages, as: MessagesResolver
  alias ReWeb.Resolvers.Channels, as: ChannelsResolver

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
    field :listing, :listing, resolve: &ChannelsResolver.get_listing/3

    field :unread_count, :integer, resolve: &MessagesResolver.count_unread/3

    field :messages, list_of(:message) do
      arg :limit, :integer
      arg :offset, :integer

      resolve &MessagesResolver.per_channel/3
    end
  end

  object :message_queries do
    @desc "List user messages, optionally by listing"
    field :listing_user_messages, :user_messages do
      arg :listing_id, :id
      arg :sender_id, :id

      resolve &MessagesResolver.get/2
    end


    @desc "Get user channels"
    field :user_channels, list_of(:channel) do
      arg :other_participant_id, :id
      arg :listing_id, :id

      resolve(&ChannelsResolver.all/2)
    end
  end

  object :message_mutations do
    @desc "Send message"
    field :send_message, type: :message do
      arg :receiver_id, non_null(:id)
      arg :listing_id, non_null(:id)

      arg :message, :string

      resolve &MessagesResolver.send/2
    end

    @desc "Mark message as read"
    field :mark_as_read, type: :message do
      arg :id, non_null(:id)

      resolve &MessagesResolver.mark_as_read/2
    end
  end

  scalar :datetime, name: "DateTime" do
    serialize(&NaiveDateTime.to_iso8601/1)
    parse(&ReWeb.Graphql.SchemaHelpers.parse_datetime/1)
  end

  object :message_subscriptions do
    @desc "Subscribe to your messages"
    field :message_sent, :message do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          %{id: receiver_id} -> {:ok, topic: receiver_id}
          _ -> {:error, :unauthenticated}
        end
      end)

      trigger :send_message,
        topic: fn message ->
          message.receiver_id
        end
    end

    @desc "Send e-mail notification for new messages"
    field :message_sent_admin, :message do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "message_sent_admin"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :send_message,
        topic: fn _ ->
          "message_sent_admin"
        end
    end
  end
end
