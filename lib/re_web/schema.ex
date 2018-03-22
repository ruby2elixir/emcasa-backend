defmodule ReWeb.Schema do
  @moduledoc """
  Module for defining graphQL schemas
  """
  use Absinthe.Schema
  import_types ReWeb.Schema.ListingTypes

  alias ReWeb.Resolvers

  query do
    @desc "Get all listings"
    field :listings, list_of(:listing) do
      resolve &Resolvers.Listings.all/2
    end
  end

  mutation do
    @desc "Activate listing"
    field :activate_listing, type: :listing do
      arg :id, non_null(:id)

      resolve &Resolvers.Listings.activate/2
    end
  end
end
