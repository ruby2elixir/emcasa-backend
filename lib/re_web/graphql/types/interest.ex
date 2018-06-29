defmodule ReWeb.Types.Interest do
  @moduledoc """
  GraphQL types for interests
  """
  use Absinthe.Schema.Notation

  alias ReWeb.Resolvers.Interests, as: InterestsResolver

  object :contact do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :message, :string
  end

  object :interest_mutations do
    @desc "Request contact"
    field :request_contact, type: :contact do
      arg :name, :string
      arg :phone, :string
      arg :email, :string
      arg :message, :string

      resolve &InterestsResolver.request_contact/2
    end
  end
end
