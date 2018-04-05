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
      resolve &Resolvers.Listings.favorited_users/2
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

      resolve &Resolvers.Listings.favorite/2
    end

    @desc "Unfavorite listing"
    field :unfavorite_listing, type: :listing do
      arg :id, non_null(:id)

      resolve &Resolvers.Listings.unfavorite/2
    end
  end
end
