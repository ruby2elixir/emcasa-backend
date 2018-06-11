defmodule ReWeb.Schema.ListingTypes do
  @moduledoc """
  GraphQL types for listings
  """
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

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

    field :address, :address, resolve: dataloader(Re.Addresses)

    field :images, list_of(:image) do
      arg :is_active, :boolean

      resolve dataloader(Re.Images)
    end
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
end
