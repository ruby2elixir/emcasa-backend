defmodule ReWeb.Types.Unit do
  @moduledoc """
  GraphQL types for units.
  """
  use Absinthe.Schema.Notation

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
  end
end
