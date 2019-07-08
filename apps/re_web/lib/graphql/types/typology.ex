defmodule ReWeb.Types.Typology do
  @moduledoc """
  Graphql type for development typologies.
  """
  use Absinthe.Schema.Notation

  alias ReWeb.Resolvers

  object :typology do
    field :area, :integer
    field :rooms, :integer
    field :min_price, :integer
    field :max_price, :integer
    field :unit_count, :integer
  end
end
