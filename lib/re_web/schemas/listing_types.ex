defmodule ReWeb.Schema.ListingTypes do
  @moduledoc """
  GraphQL types for listings
  """
  use Absinthe.Schema.Notation

  alias Re.Address

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
    field :area, :integer
    field :garage_spots, :integer
    field :suites, :integer
    field :dependencies, :integer
    field :has_elevator, :boolean
    field :matterport_code, :string
    field :is_active, :boolean
    field :is_exclusive, :boolean

    # field :images, list_of(:image)

    field :address, :address do
      resolve fn listing, _, _ ->
        batch(
          {ReWeb.Schema.Helpers, :by_id, Address},
          listing.address_id,
          &({:ok, Map.get(&1, listing.address_id)})
        )
      end
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
  end
end
