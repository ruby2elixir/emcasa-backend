defmodule ReWeb.Schema.UserTypes do
  @moduledoc """
  GraphQL types for users
  """
  use Absinthe.Schema.Notation

  object :user do
    field :id, :id
    field :name, :string
    field :email, :string
    field :phone, :string
    field :role, :string
  end
end
