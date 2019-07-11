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

  enum :deactivation_reason, values: ~w(duplicated gave_up left_emcasa publication_mistake rented
                                        rejected sold sold_by_emcasa temporarily_suspended to_be_published
                                        went_exclusive)

  enum :garage_type, values: ~w(contract condominium)

  enum :orientation_type, values: ~w(frontside backside lateral inside)

  enum :sun_period_type, values: ~w(morning evening)

  object :listing do
    field :id, :id
    field :uuid, :uuid, resolve: &Resolvers.Listings.get_uuid/3
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
    field :is_exportable, :boolean
    field :orientation, :orientation_type
    field :floor_count, :integer
    field :unit_per_floor, :integer
    field :sun_period, :sun_period_type
    field :elevators, :integer
    field :construction_year, :integer
    field :price_per_area, :float
    field :inserted_at, :naive_datetime
    field :score, :integer, resolve: &Resolvers.Listings.score/3
    field :deactivation_reason, :deactivation_reason
    field :sold_price, :integer
    field :liquidity_ratio, :float

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

    field :units, list_of(:unit), resolve: &Resolvers.Units.per_listing/3

    field :development, :development, resolve: &Resolvers.Developments.per_listing/3

    field :tags, list_of(:tag), resolve: &Resolvers.Tags.per_listing/3

    field :owner_contact, :owner_contact, resolve: &Resolvers.OwnerContacts.per_listing/3
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
    field :is_exportable, :boolean
    field :score, :integer
    field :orientation, :orientation_type
    field :floor_count, :integer
    field :unit_per_floor, :integer
    field :sun_period, :sun_period_type
    field :elevators, :integer
    field :construction_year, :integer

    field :phone, :string

    field :address, :address_input
    field :address_id, :id

    field :development_uuid, :uuid

    field :tags, list_of(non_null(:uuid))

    field :owner_contact, :owner_contact_input
    field :deactivation_reason, :deactivation_reason
  end

  input_object :deactivation_options_input do
    field :deactivation_reason, non_null(:deactivation_reason)
    field :sold_price, :integer
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
      ~w(id price property_tax maintenance_fee rooms bathrooms restrooms area garage_spots suites dependencies balconies
      price_per_area inserted_at floor)a

  enum :order_type, values: ~w(desc asc)a

  input_object :listing_filter_input do
    field :max_price, :integer
    field :min_price, :integer
    field :max_rooms, :integer
    field :min_rooms, :integer
    field :max_suites, :integer
    field :min_suites, :integer
    field :max_bathrooms, :integer
    field :min_bathrooms, :integer
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
    field :statuses, list_of(non_null(:string))
    field :tags_slug, list_of(non_null(:string))
    field :tags_uuid, list_of(non_null(:uuid))
    field :min_floor_count, :integer
    field :max_floor_count, :integer
    field :min_unit_per_floor, :integer
    field :max_unit_per_floor, :integer
    field :orientations, list_of(non_null(:orientation_type))
    field :sun_periods, list_of(non_null(:sun_period_type))
    field :min_age, :integer
    field :max_age, :integer
    field :min_price_per_area, :float
    field :max_price_per_area, :float
    field :min_maintenance_fee, :float
    field :max_maintenance_fee, :float
    field :is_release, :boolean
    field :exclude_similar_for_primary_market, :boolean
  end

  object :listing_filter do
    field :max_price, :integer
    field :min_price, :integer
    field :max_rooms, :integer
    field :min_rooms, :integer
    field :max_suites, :integer
    field :min_suites, :integer
    field :max_bathrooms, :integer
    field :min_bathrooms, :integer
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
    field :statuses, list_of(:string)
    field :tags_slug, list_of(:string)
    field :tags_uuid, list_of(:uuid)
    field :min_floor_count, :integer
    field :max_floor_count, :integer
    field :min_unit_per_floor, :integer
    field :max_unit_per_floor, :integer
    field :orientations, list_of(non_null(:orientation_type))
    field :sun_periods, list_of(non_null(:sun_period_type))
    field :min_age, :integer
    field :max_age, :integer
    field :min_price_per_area, :float
    field :max_price_per_area, :float
    field :is_release, :boolean
    field :exclude_similar_for_primary_market, :boolean
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

    @desc "Featured listings"
    field :featured_listings, list_of(:listing), resolve: &Resolvers.Listings.featured/2

    @desc "Get listings with relaxed filters"
    field :relaxed_listings, :listing_index do
      arg :pagination, :listing_pagination
      arg :filters, :listing_filter_input
      arg :order_by, list_of(:order_by)

      resolve &Resolvers.Listings.relaxed/2
    end
  end

  object :listing_mutations do
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
      arg :input, :deactivation_options_input

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

    @desc "Tour visualization"
    field :tour_visualized, type: :listing do
      arg :id, non_null(:id)

      resolve &Resolvers.ListingStats.tour_visualized/2
    end
  end

  object :listing_subscriptions do
    @desc "Subscribe to listing activation"
    field :listing_activated, :listing do
      arg :id, non_null(:id)

      config &Resolvers.Listings.listing_activated_config/2

      trigger :activate_listing, topic: &Resolvers.Listings.listing_activate_trigger/1
    end

    @desc "Subscribe to listing deactivation"
    field :listing_deactivated, :listing do
      arg :id, non_null(:id)
      config &Resolvers.Listings.listing_deactivated_config/2

      trigger :deactivate_listing, topic: &Resolvers.Listings.listing_deactivate_trigger/1
    end

    @desc "Subscribe to listing show"
    field :listing_inserted, :listing do
      config &Resolvers.Listings.listing_inserted_config/2

      trigger :insert_listing, topic: &Resolvers.Listings.insert_listing_trigger/1
    end

    @desc "Subscribe to listing update"
    field :listing_updated, :listing do
      arg :id, non_null(:id)

      config &Resolvers.Listings.listing_updated_config/2

      trigger :update_listing, topic: &Resolvers.Listings.update_listing_trigger/1
    end
  end
end
