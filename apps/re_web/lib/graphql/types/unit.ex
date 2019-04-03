defmodule ReWeb.Types.Unit do
  @moduledoc """
  GraphQL types for units.
  """
  use Absinthe.Schema.Notation

  alias ReWeb.Resolvers

  object :unit do
    field :uuid, :uuid
    field :complement, :string
    field :price, :integer
    field :property_tax, :float
    field :maintenance_fee, :float
    field :floor, :string
    field :rooms, :integer
    field :bathrooms, :integer
    field :restrooms, :integer
    field :area, :integer
    field :garage_spots, :integer
    field :garage_type, :string
    field :suites, :integer
    field :dependencies, :integer
    field :balconies, :integer
    field :status, :string
  end

  input_object :unit_input do
    field :complement, :string
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
    field :status, :string
    field :development_uuid, non_null(:uuid)
    field :listing_id, non_null(:id)
  end

  object :unit_mutations do
    @desc "Insert unit"
    field :add_unit, type: :unit do
      arg :input, non_null(:unit_input)

      resolve &Resolvers.Units.insert/2
    end

    @desc "Update unit"
    field :update_unit, type: :unit do
      arg :uuid, non_null(:uuid)
      arg :input, non_null(:unit_input)

      resolve &Resolvers.Units.update/2
    end
  end
end
