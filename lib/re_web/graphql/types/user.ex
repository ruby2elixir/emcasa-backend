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

    field :blacklists, list_of(:listing) do
      arg :pagination, non_null(:listing_pagination)
      arg :filters, non_null(:listing_filter_input)

      resolve &ListingsResolver.blacklists/3
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
  end

  object :user_mutations do
    @desc "Sign in"
    field :sign_in, type: :credentials do
      arg :email, non_null(:string)
      arg :password, non_null(:string)

      resolve &AccountsResolver.sign_in/2
    end

    @desc "Sign in"
    field :account_kit_sign_in, type: :credentials do
      arg :auth_code, non_null(:string)

      resolve &AccountsResolver.account_kit_sign_in/2
    end

    @desc "Register"
    field :register, type: :credentials do
      arg :name, non_null(:string)
      arg :email, non_null(:string)
      arg :phone, :string
      arg :password, non_null(:string)
      arg :device_token, :string

      resolve &AccountsResolver.register/2
    end

    @desc "Confirm registration"
    field :confirm, type: :credentials do
      arg :token, non_null(:string)

      resolve &AccountsResolver.confirm/2
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

    @desc "Change password"
    field :change_password, type: :user do
      arg :id, non_null(:id)
      arg :current_password, :string
      arg :new_password, :string

      resolve &AccountsResolver.change_password/2
    end

    @desc "Request password reset"
    field :reset_password, type: :user do
      arg :email, non_null(:string)

      resolve &AccountsResolver.reset_password/2
    end

    @desc "Request password redefinition"
    field :redefine_password, type: :user do
      arg :reset_token, non_null(:string)
      arg :new_password, non_null(:string)

      resolve &AccountsResolver.redefine_password/2
    end
  end

  object :user_subscriptions do
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

    @desc "Subscribe to user registration"
    field :user_registered, :credentials do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "user_registered"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :register,
        topic: fn _ ->
          "user_registered"
        end
    end

    @desc "Subscribe to user confirmation"
    field :user_confirmed, :credentials do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "user_confirmed"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :confirm,
        topic: fn _ ->
          "user_confirmed"
        end
    end

    @desc "Subscribe to password reset"
    field :password_reset_requested, :user do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "password_reset_requested"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :reset_password,
        topic: fn _ ->
          "password_reset_requested"
        end
    end
  end
end
