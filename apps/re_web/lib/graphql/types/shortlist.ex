defmodule ReWeb.Types.Shortlist do
  @moduledoc """
  Graphql type for shortlists.
  """
  use Absinthe.Schema.Notation

  alias ReWeb.Resolvers

  object :shortlist_queries do
    @desc "Shortlist index"
    field :shortlist_listings, list_of(:listing) do
      arg :opportunity_id, non_null(:string)

      resolve &Resolvers.Shortlists.index/2
    end
  end
end
