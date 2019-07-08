defmodule ReWeb.Types.Address do
  @moduledoc """
  GraphQL types for addresses
  """
  use Absinthe.Schema.Notation

  alias ReWeb.Resolvers

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
    field :status, :string
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

  object :address_queries do
    @desc "Get all districts"
    field :districts, list_of(:district), resolve: &Resolvers.Addresses.districts/2

    @desc "Show district"
    field :district, :district do
      arg :state_slug, non_null(:string)
      arg :city_slug, non_null(:string)
      arg :name_slug, non_null(:string)

      resolve &Resolvers.Addresses.district/2
    end

    @desc "Get address coverage"
    field :address_is_covered, :boolean do
      arg :state, non_null(:string)
      arg :city, non_null(:string)
      arg :neighborhood, non_null(:string)

      resolve &Resolvers.Addresses.is_covered/2
    end
  end

  object :address_mutations do
    @desc "Insert address"
    field :address_insert, type: :address do
      arg :input, non_null(:address_input)

      resolve &Resolvers.Addresses.insert/2
    end
  end
end
