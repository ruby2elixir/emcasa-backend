defmodule ReWeb.Types.Tag do
  @moduledoc """
  Graphql type for tags.
  """
  use Absinthe.Schema.Notation

  alias ReWeb.Resolvers

  object :tag do
    field :uuid, :uuid
    field :name, :string
    field :name_slug, :string
    field :category, :string
    field :visibility, :string
  end

  input_object :tag_input do
    field :name, non_null(:string)
    field :category, non_null(:string)
    field :visibility, non_null(:string)
  end

  object :tag_queries do
    @desc "Tags index"
    field :tags, list_of(:tag) do
      resolve &Resolvers.Tags.index/2
    end

    @desc "Tags search"
    field :tags_search, list_of(:tag) do
      arg :name, non_null(:string)

      resolve &Resolvers.Tags.search/2
    end

    @desc "Show tag"
    field :tag, :tag do
      arg :uuid, non_null(:uuid)

      resolve &Resolvers.Tags.show/2
    end
  end
end
