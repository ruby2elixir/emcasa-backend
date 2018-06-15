defmodule ReWeb.Schema do
  @moduledoc """
  Module for defining graphQL schemas
  """
  use Absinthe.Schema

  import_types ReWeb.Types.{Listing, User, Message}

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias ReWeb.Resolvers

  def context(ctx), do: Map.put(ctx, :loader, loader(ctx))

  def plugins, do: [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]

  query do
    @desc "Get listings"
    field :listings, :listing_index do
      arg :pagination, :listing_pagination
      arg :filters, :listing_filter

      resolve &Resolvers.Listings.index/2
    end

    @desc "Get listings"
    field :listing, :listing do
      arg :id, non_null(:id)

      resolve &Resolvers.Listings.show/2
    end

    @desc "Get favorited listings"
    field :favorited_listings, list_of(:listing), resolve: &Resolvers.Accounts.favorited/2

    @desc "Get favorited users"
    field :show_favorited_users, list_of(:user) do
      arg :id, non_null(:id)
      resolve &Resolvers.Favorites.favorited_users/2
    end

    @desc "List user messages, optionally by listing"
    field :listing_user_messages, :user_messages do
      arg :listing_id, :id
      arg :sender_id, :id

      resolve &Resolvers.Messages.get/2
    end

    @desc "List user listings"
    field :user_listings, list_of(:listing), do: resolve(&Resolvers.Listings.per_user/2)

    @desc "Get user profile"
    field :user_profile, :user do
      arg :id, non_null(:id)

      resolve &Resolvers.Accounts.profile/2
    end

    @desc "Get user channels"
    field :user_channels, list_of(:channel), do: resolve(&Resolvers.Channels.all/2)
  end

  mutation do
    import_fields(:listing_mutations)
    import_fields(:message_mutations)
    import_fields(:user_mutations)
  end

  subscription do
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

    @desc "Subscribe to listing activation"
    field :listing_activated, :listing do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "listing_activated"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :activate_listing,
        topic: fn _ ->
          "listing_activated"
        end
    end

    @desc "Subscribe to listing deactivation"
    field :listing_deactivated, :listing do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "listing_deactivated"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :deactivate_listing,
        topic: fn _ ->
          "listing_deactivated"
        end
    end

    @desc "Subscribe to email change"
    field :email_changed, :listing do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "email_changed"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :change_email,
        topic: fn _ ->
          "email_changed"
        end
    end
  end

  defp loader(ctx) do
    default_params = default_params(ctx)

    Enum.reduce(
      sources(),
      Dataloader.new(),
      &Dataloader.add_source(&2, &1, :erlang.apply(&1, :data, [default_params]))
    )
  end

  defp default_params(%{current_user: current_user}), do: %{current_user: current_user}
  defp default_params(_), do: %{current_user: nil}

  defp sources do
    [
      Re.Accounts,
      Re.Addresses,
      Re.Images,
      Re.Listings
    ]
  end
end
