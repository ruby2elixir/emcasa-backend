defmodule ReWeb.Types.Listing do
  @moduledoc """
  GraphQL types for listings
  """
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  alias ReWeb.{
    GraphQL.Middlewares,
    Resolvers
  }

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
    field :garage_type, :garage_type
    field :suites, :integer
    field :dependencies, :integer
    field :balconies, :integer
    field :has_elevator, :boolean
    field :matterport_code, :string
    field :is_active, :boolean, resolve: &Resolvers.Listings.is_active/3
    field :is_exclusive, :boolean
    field :is_release, :boolean
    field :inserted_at, :naive_datetime
    field :score, :integer, resolve: &Resolvers.Listings.score/3

    field :address, :address,
      resolve: dataloader(Re.Addresses, &Resolvers.Addresses.per_listing/3)

    field :images, list_of(:image) do
      arg :is_active, :boolean
      arg :limit, :integer

      resolve &Resolvers.Images.per_listing/3
    end

    field :owner, :user, resolve: &Resolvers.Accounts.owner/3

    field :interest_count, :integer, resolve: &Resolvers.Statistics.interest_count/3
    field :in_person_visit_count, :integer, resolve: &Resolvers.Statistics.in_person_visit_count/3

    field :listing_favorite_count, :integer,
      resolve: &Resolvers.Statistics.listings_favorite_count/3

    field :tour_visualisation_count, :integer,
      resolve: &Resolvers.Statistics.tour_visualisation_count/3

    field :listing_visualisation_count, :integer,
      resolve: &Resolvers.Statistics.listing_visualisation_count/3

    field :previous_prices, list_of(:price_history), resolve: &Resolvers.Listings.price_history/3
    field :suggested_price, :float, resolve: &Resolvers.Listings.suggested_price/3
    field :price_recently_reduced, :boolean, resolve: &Resolvers.Listings.price_recently_reduced/3

    field :related, :listing_index do
      arg :pagination, non_null(:listing_pagination)
      arg :filters, non_null(:listing_filter_input)

      resolve &Resolvers.Listings.related/3
    end

    field :vivareal_highlight, :boolean, resolve: &Resolvers.Listings.vivareal_highlight/3
    field :zap_highlight, :boolean, resolve: &Resolvers.Listings.zap_highlight/3
    field :zap_super_highlight, :boolean, resolve: &Resolvers.Listings.zap_super_highlight/3
  end

  input_object :listing_input do
    field :type, non_null(:string)
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
    field :garage_type, :garage_type
    field :suites, :integer
    field :dependencies, :integer
    field :balconies, :integer
    field :has_elevator, :boolean
    field :matterport_code, :string
    field :is_exclusive, :boolean
    field :is_release, :boolean
    field :score, :integer

    field :phone, :string

    field :address, :address_input
    field :address_id, :id
  end

  enum :garage_type, values: ~w(contract condominium)

  object :address do
    field :id, :id
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

    field :neighborhood_description, :string,
      resolve: &Resolvers.Addresses.neighborhood_description/3

    field :is_covered, :boolean, resolve: &Resolvers.Addresses.is_covered/3
  end

  object :district do
    field :state, :string
    field :city, :string
    field :name, :string
    field :state_slug, :string
    field :city_slug, :string
    field :name_slug, :string
    field :description, :string
  end

  input_object :address_input do
    field :street, non_null(:string)
    field :street_number, non_null(:string)
    field :neighborhood, non_null(:string)
    field :city, non_null(:string)
    field :state, non_null(:string)
    field :postal_code, non_null(:string)
    field :lat, non_null(:float)
    field :lng, non_null(:float)
  end

  object :image do
    field :id, :id
    field :filename, :string
    field :position, :integer
    field :is_active, :boolean
    field :description, :string
  end

  input_object :image_insert_input do
    field :listing_id, non_null(:id)
    field :filename, non_null(:string)
    field :is_active, :boolean
    field :description, :string
  end

  input_object :image_update_input do
    field :id, non_null(:id)
    field :position, :integer
    field :description, :string
  end

  object :listing_user do
    field :listing, :listing
    field :user, :user
  end

  object :listing_index do
    field :listings, list_of(:listing)
    field :remaining_count, :integer
    field :filters, :listing_filter
  end

  input_object :listing_pagination do
    field :page_size, :integer
    field :excluded_listing_ids, list_of(:id)
  end

  input_object :order_by do
    field :field, :orderable_field
    field :type, :order_type
  end

  enum :orderable_field,
    values:
      ~w(id price property_tax maintenance_fee rooms bathrooms restrooms area garage_spots suites dependencies balconies)a

  enum :order_type, values: ~w(desc asc)a

  input_object :listing_filter_input do
    field :max_price, :integer
    field :min_price, :integer
    field :max_rooms, :integer
    field :min_rooms, :integer
    field :max_suites, :integer
    field :min_suites, :integer
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
    field :garage_types, list_of(:garage_type)
    field :cities, list_of(:string)
    field :cities_slug, list_of(:string)
  end

  object :listing_filter do
    field :max_price, :integer
    field :min_price, :integer
    field :max_rooms, :integer
    field :min_rooms, :integer
    field :max_suites, :integer
    field :min_suites, :integer
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
    field :garage_types, list_of(:garage_type)
    field :cities, list_of(:string)
    field :cities_slug, list_of(:string)
  end

  object :price_history do
    field :price, :integer
    field :inserted_at, :naive_datetime
  end

  object :listing_queries do
    @desc "Listings index"
    field :listings, :listing_index do
      arg :pagination, :listing_pagination
      arg :filters, :listing_filter_input
      arg :order_by, list_of(:order_by)

      resolve &Resolvers.Listings.index/2
    end

    @desc "Show listing"
    field :listing, :listing do
      arg :id, non_null(:id)

      resolve &Resolvers.Listings.show/2
      middleware(Middlewares.Visualizations)
    end

    @desc "List user listings"
    field :user_listings, list_of(:listing), do: resolve(&Resolvers.Listings.per_user/2)

    @desc "Get favorited listings"
    field :favorited_listings, list_of(:listing), resolve: &Resolvers.Accounts.favorited/2

    @desc "Get all neighborhoods"
    field :neighborhoods, list_of(:string), resolve: &Resolvers.Listings.neighborhoods/2

    @desc "Get all districts"
    field :districts, list_of(:district), resolve: &Resolvers.Addresses.districts/2

    @desc "Show district"
    field :district, :district do
      arg :state_slug, non_null(:string)
      arg :city_slug, non_null(:string)
      arg :name_slug, non_null(:string)

      resolve &Resolvers.Addresses.district/2
    end

    @desc "Featured listings"
    field :featured_listings, list_of(:listing), resolve: &Resolvers.Listings.featured/2

    @desc "Get listings with relaxed filters"
    field :relaxed_listings, :listing_index do
      arg :pagination, :listing_pagination
      arg :filters, :listing_filter_input
      arg :order_by, list_of(:order_by)

      resolve &Resolvers.Listings.relaxed/2
    end

    @desc "Get address coverage"
    field :address_is_covered, :boolean do
      arg :state, non_null(:string)
      arg :city, non_null(:string)
      arg :neighborhood, non_null(:string)

      resolve &Resolvers.Addresses.is_covered/2
    end
  end

  object :listing_mutations do
    @desc "Insert address"
    field :address_insert, type: :address do
      arg :input, non_null(:address_input)

      resolve &Resolvers.Addresses.insert/2
    end

    @desc "Insert listing"
    field :insert_listing, type: :listing do
      arg :input, non_null(:listing_input)

      resolve &Resolvers.Listings.insert/2
    end

    @desc "Update listing"
    field :update_listing, type: :listing do
      arg :id, non_null(:id)
      arg :input, non_null(:listing_input)

      resolve &Resolvers.Listings.update/2
    end

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

      resolve &Resolvers.Favorites.add/2
    end

    @desc "Unfavorite listing"
    field :unfavorite_listing, type: :listing_user do
      arg :id, non_null(:id)

      resolve &Resolvers.Favorites.remove/2
    end

    @desc "Blacklist listing"
    field :listing_blacklist, type: :listing_user do
      arg :id, non_null(:id)

      resolve &Resolvers.Blacklists.add/2
    end

    @desc "Unblacklist listing"
    field :listing_unblacklist, type: :listing_user do
      arg :id, non_null(:id)

      resolve &Resolvers.Blacklists.remove/2
    end

    @desc "Tour visualization"
    field :tour_visualized, type: :listing do
      arg :id, non_null(:id)

      resolve &Resolvers.ListingStats.tour_visualized/2
    end

    @desc "Inser image"
    field :insert_image, type: :image do
      arg :input, non_null(:image_insert_input)

      resolve &Resolvers.Images.insert_image/2
    end

    @desc "Update images"
    field :update_images, type: list_of(:image) do
      arg :input, non_null(list_of(non_null(:image_update_input)))

      resolve &Resolvers.Images.update_images/2
    end
  end

  object :listing_subscriptions do
    @desc "Subscribe to listing activation"
    field :listing_activated, :listing do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "listing_activated"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :activate_listing,
        topic: fn _ ->
          "listing_activated"
        end
    end

    @desc "Subscribe to listing deactivation"
    field :listing_deactivated, :listing do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "listing_deactivated"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :deactivate_listing,
        topic: fn _ ->
          "listing_deactivated"
        end
    end

    @desc "Subscribe to listing show"
    field :listing_inserted, :listing do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "listing_inserted"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :insert_listing,
        topic: fn _ ->
          "listing_inserted"
        end
    end
  end
end
