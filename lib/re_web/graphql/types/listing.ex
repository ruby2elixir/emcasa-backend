defmodule ReWeb.Types.Listing do
  @moduledoc """
  GraphQL types for listings
  """
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  alias ReWeb.Resolvers

  object :listing do
    field :id, :id
    field :type, :string
    field :complement, :string
    field :description, :string
    field :price, :integer
    field :property_tax, :float
    field :maintenance_fee, :float
    field :floor, :string
    field :rooms, :integer
    field :bathrooms, :integer
    field :restrooms, :integer
    field :area, :integer
    field :garage_spots, :integer
    field :suites, :integer
    field :dependencies, :integer
    field :balconies, :integer
    field :has_elevator, :boolean
    field :matterport_code, :string
    field :is_active, :boolean
    field :is_exclusive, :boolean
    field :is_release, :boolean

    field :address, :address,
      resolve: dataloader(Re.Addresses, &Resolvers.Addresses.per_listing/3)

    field :images, list_of(:image) do
      arg :is_active, :boolean
      arg :limit, :integer

      resolve dataloader(Re.Images, &Resolvers.Images.per_listing/3)
    end

    field :owner, :user, resolve: &Resolvers.Accounts.owner/3
  end

  object :address do
    field :street, :string
    field :street_number, :string
    field :neighborhood, :string
    field :city, :string
    field :state, :string
    field :postal_code, :string
    field :lat, :float
    field :lng, :float

    field :street_slug, :string
    field :neighborhood_slug, :string
    field :city_slug, :string
    field :state_slug, :string
  end

  object :image do
    field :filename, :string
    field :position, :integer
    field :is_active, :boolean
    field :description, :string
  end

  object :listing_user do
    field :listing, :listing
    field :user, :user
  end

  object :listing_index do
    field :listings, list_of(:listing)
    field :remaining_count, :integer
  end

  input_object :listing_pagination do
    field :page_size, :integer
    field :excluded_listing_ids, list_of(:id)
  end

  input_object :listing_filter do
    field :max_price, :integer
    field :min_price, :integer
    field :max_rooms, :integer
    field :min_rooms, :integer
    field :min_area, :integer
    field :max_area, :integer
    field :neighborhoods, list_of(:string)
    field :types, list_of(:string)
    field :max_lat, :float
    field :min_lat, :float
    field :max_lng, :float
    field :min_lng, :float
    field :neighborhoods_slugs, list_of(:string)
    field :max_garage_spots, :integer
    field :min_garage_spots, :integer
  end

  object :listing_mutations do
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

      resolve &Resolvers.Favorites.favorite/2
    end

    @desc "Unfavorite listing"
    field :unfavorite_listing, type: :listing_user do
      arg :id, non_null(:id)

      resolve &Resolvers.Favorites.unfavorite/2
    end

    @desc "Tour visualization"
    field :tour_visualized, type: :listing do
      arg :id, non_null(:id)

      resolve &Resolvers.ListingStats.tour_visualized/2
    end
  end
end
