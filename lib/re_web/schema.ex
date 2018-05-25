defmodule ReWeb.Schema do
  @moduledoc """
  Module for defining graphQL schemas
  """
  use Absinthe.Schema
  import_types ReWeb.Schema.ListingTypes
  import_types ReWeb.Schema.UserTypes

  alias ReWeb.Resolvers

  query do
    @desc "Get favorited listings"
    field :favorited_listings, list_of(:listing) do
      resolve &Resolvers.Users.favorited/2
    end

    @desc "Get favorited users"
    field :show_favorited_users, list_of(:user) do
      arg :id, non_null(:id)
      resolve &Resolvers.Favorites.favorited_users/2
    end

    @desc "List user messages, optionally by listing"
    field :listing_user_messages, list_of(:message) do
      arg :listing_id, :id
      arg :sender_id, :id

      resolve &Resolvers.Messages.get/2
    end

    @desc "List user listings"
    field :user_listings, list_of(:listing) do
      resolve &Resolvers.Listings.per_user/2
    end

    @desc "Get user profile"
    field :user_profile, :user do
      arg :id, non_null(:id)

      resolve &Resolvers.Users.profile/2
    end
  end

  mutation do
    @desc "Activate listing"
    field :activate_listing, type: :listing do
      arg :id, non_null(:id)

      resolve &Resolvers.Listings.activate/2
    end

    @desc "Deactivate listing"
    field :deactivate_listing, type: :listing do
      arg :id, non_null(:id)

      resolve &Resolvers.Listings.deactivate/2
    end

    @desc "Favorite listing"
    field :favorite_listing, type: :listing_user do
      arg :id, non_null(:id)

      resolve &Resolvers.Favorites.favorite/2
    end

    @desc "Unfavorite listing"
    field :unfavorite_listing, type: :listing_user do
      arg :id, non_null(:id)

      resolve &Resolvers.Favorites.unfavorite/2
    end

    @desc "Tour visualization"
    field :tour_visualized, type: :listing do
      arg :id, non_null(:id)

      resolve &Resolvers.ListingStats.tour_visualized/2
    end

    @desc "Send message"
    field :send_message, type: :message do
      arg :receiver_id, non_null(:id)
      arg :listing_id, :id

      arg :message, :string

      resolve &Resolvers.Messages.send/2
    end

    @desc "Edit user profile"
    field :edit_user_profile, type: :user do
      arg :id, non_null(:id)
      arg :name, :string
      arg :phone, :string

      resolve &Resolvers.Users.edit_profile/2
    end

    @desc "Change email"
    field :change_email, type: :user do
      arg :id, non_null(:id)
      arg :email, :string

      resolve &Resolvers.Users.change_email/2
    end

    @desc "Change password"
    field :change_password, type: :user do
      arg :id, non_null(:id)
      arg :current_password, :string
      arg :new_password, :string

      resolve &Resolvers.Users.change_password/2
    end
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
end
