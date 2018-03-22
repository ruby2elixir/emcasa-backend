defmodule ReWeb.Schema.ListingTypes do
  use Absinthe.Schema.Notation

  object :listing do
    field :id, :id
  end
end
