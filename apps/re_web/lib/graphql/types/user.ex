defmodule ReWeb.Types.User do
  @moduledoc """
  GraphQL types for users
  """
  use Absinthe.Schema.Notation

  alias ReWeb.Resolvers.Accounts, as: AccountsResolver
  alias ReWeb.Resolvers.Listings, as: ListingsResolver
  alias ReWeb.Resolvers.Favorites, as: FavoritesResolver

  object :user do
    field :id, :id
    field :uuid, :uuid
    field :name, :string
    field :email, :string
    field :phone, :string
    field :role, :string
    field :notification_preferences, :notification_preferences

    field :favorites, list_of(:listing) do
      arg :pagination, non_null(:listing_pagination)
      arg :filters, non_null(:listing_filter_input)

      resolve &ListingsResolver.favorites/3
    end

    field :listings, list_of(:listing) do
      arg :pagination, non_null(:listing_pagination)
      arg :filters, non_null(:listing_filter_input)

      resolve &ListingsResolver.owned/3
    end
  end

  object :notification_preferences do
    field :email, :boolean
    field :app, :boolean
  end

  object :credentials do
    field :jwt, :string
    field :user, :user
  end

  input_object :notification_preferences_input do
    field :email, :boolean
    field :app, :boolean
  end

  input_object :pagination_input do
    field :page, :integer
    field :page_size, :integer
  end

  object :user_queries do
    @desc "Get favorited users"
    field :show_favorited_users, list_of(:user) do
      arg :id, non_null(:id)

      resolve &FavoritesResolver.users/2
    end

    @desc "Get user profile"
    field :user_profile, :user do
      arg :id, :id

      resolve &AccountsResolver.profile/2
    end

    @desc "Get user list"
    field :users, list_of(:user) do
      arg :pagination, :pagination_input

      resolve &AccountsResolver.users/2
    end
  end

  object :user_mutations do
    @desc "Sign in through account kit"
    field :account_kit_sign_in, type: :credentials do
      arg :access_token, non_null(:string)

      resolve &AccountsResolver.account_kit_sign_in/2
    end

    @desc "Edit user profile"
    field :edit_user_profile, type: :user do
      arg :id, non_null(:id)
      arg :name, :string
      arg :phone, :string
      arg :notification_preferences, :notification_preferences_input
      arg :device_token, :string

      resolve &AccountsResolver.edit_profile/2
    end

    @desc "Change email"
    field :change_email, type: :user do
      arg :id, non_null(:id)
      arg :email, :string

      resolve &AccountsResolver.change_email/2
    end

    @desc "Promote an user to admin role"
    field :user_update_role_to_admin, type: :user do
      arg :uuid, non_null(:uuid)

      resolve &AccountsResolver.change_role/2
    end
  end
end
