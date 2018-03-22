defmodule ReWeb.Schema do
  use Absinthe.Schema
  import_types ReWeb.Schema.ContentTypes

  alias ReWeb.Resolvers

  query do

    @desc "Get paginated listings"
    field :paginated_listing, :paginated_listing do
      resolve &Resolvers.Content.paginated_listing/2
    end

  end

end
