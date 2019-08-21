defmodule ReWeb.Types.DuplicityChecker do
  @moduledoc """
  GraphQL types for duplicity checking
  """
  use Absinthe.Schema.Notation

  alias ReWeb.Resolvers

  object :duplicity_checking_queries do
    @desc "Check for an address and complement is duplicated"
    field :check_duplicity, :boolean do
      arg :complement, :string
      arg :address, non_null(:address_input)

      resolve &Resolvers.DuplicityChecker.duplicated?/2
    end
  end
end
