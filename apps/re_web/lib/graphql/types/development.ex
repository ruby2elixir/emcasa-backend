defmodule ReWeb.Types.Development do
  @moduledoc """
  GraphQL types for developments
  """
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  alias ReWeb.Resolvers

  object :development do
    field :id, :id
    field :name, :string
    field :title, :string
    field :phase, :string
    field :builder, :string
    field :description, :string

    field :address, :address, resolve: dataloader(Re.Addresses, &Resolvers.Addresses.per_development/3)

    field :images, list_of(:image), resolve: &Resolvers.Images.per_development/3
  end

  object :development_queries do

    @desc "Developments index"
    field :developments, list_of(:development) do
      resolve &Resolvers.Developments.index/2
    end
  end
end
