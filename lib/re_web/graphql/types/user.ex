defmodule ReWeb.Types.User do
  @moduledoc """
  GraphQL types for users
  """
  use Absinthe.Schema.Notation

  alias ReWeb.Resolvers.Accounts, as: AccountsResolver

  object :user do
    field :id, :id
    field :name, :string
    field :email, :string
    field :phone, :string
    field :role, :string
    field :notification_preferences, :notification_preferences
  end

  object :notification_preferences do
    field :email, :boolean
    field :app, :boolean
  end

  input_object :notification_preferences_input do
    field :email, :boolean
    field :app, :boolean
  end

  object :user_mutations do
    @desc "Edit user profile"
    field :edit_user_profile, type: :user do
      arg :id, non_null(:id)
      arg :name, :string
      arg :phone, :string
      arg :notification_preferences, :notification_preferences_input

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
  end
end
