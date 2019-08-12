defmodule ReWeb.Types.User do
  @moduledoc """
  GraphQL types for users
  """
  use Absinthe.Schema.Notation

  alias ReWeb.Resolvers.Accounts, as: AccountsResolver
  alias ReWeb.Resolvers.Listings, as: ListingsResolver
  alias ReWeb.Resolvers.Favorites, as: FavoritesResolver
  alias ReWeb.Resolvers.Addresses, as: AddressesResolver

  object :user do
    field :id, :id
    field :uuid, :uuid
    field :name, :string
    field :email, :string
    field :phone, :string
    field :role, :string
    field :type, :string

    field :districts, list_of(:district) do
      resolve &AddressesResolver.districts_by_user/2
    end

    field :notification_preferences, :notification_preferences do
      deprecate("not used anymore")
    end

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

  object :user_pagination do
    field :entries, list_of(:user)
    field :page_number, :integer
    field :page_size, :integer
    field :total_pages, :integer
    field :total_entries, :integer
  end

  enum :user_role, values: ~w(admin user)

  input_object :notification_preferences_input do
    field :email, :boolean
    field :app, :boolean
  end

  input_object :pagination_input do
    field :page, non_null(:integer)
    field :page_size, non_null(:integer)
  end

  input_object :user_search_input do
    field :search, non_null(:string)
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
    field :users, :user_pagination do
      arg :pagination, :pagination_input
      arg :search, :user_search_input

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
      arg :type, :string

      resolve &AccountsResolver.edit_profile/2
    end

    @desc "Change email"
    field :change_email, type: :user do
      arg :id, non_null(:id)
      arg :email, :string

      resolve &AccountsResolver.change_email/2
    end

    @desc "Promote an user to admin role"
    field :user_update_role, type: :user do
      arg :uuid, non_null(:uuid)
      arg :role, non_null(:user_role)

      resolve &AccountsResolver.change_role/2
    end

    @desc "Edits and user so it became a partner broker"
    field :edit_broker_districts, type: :user do
      arg :id, non_null(:id)
      arg :districts, non_null(list_of(:string))

      resolve &AccountsResolver.edit_broker_districts/2
    end
  end
end
