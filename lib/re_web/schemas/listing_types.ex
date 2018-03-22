defmodule ReWeb.Schema.ListingTypes do
  @moduledoc """
  GraphQL types for listings
  """
  use Absinthe.Schema.Notation

  object :listing do
    field :id, :id
  end
end
