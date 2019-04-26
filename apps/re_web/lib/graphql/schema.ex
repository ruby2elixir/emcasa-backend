defmodule ReWeb.Schema do
  @moduledoc """
  Module for defining graphQL schemas
  """
  use Absinthe.Schema

  import_types ReWeb.Types.Listing
  import_types ReWeb.Types.Image
  import_types ReWeb.Types.User
  import_types ReWeb.Types.Interest
  import_types ReWeb.Types.Dashboard
  import_types ReWeb.Types.Calendar
  import_types ReWeb.Types.Development
  import_types ReWeb.Types.Unit
  import_types ReWeb.Types.Tag
  import_types ReWeb.Types.OwnerContact
  import_types ReWeb.Types.Custom.UUID
  import_types Absinthe.Type.Custom

  alias ReWeb.GraphQL.Middlewares

  def context(ctx), do: Map.put(ctx, :loader, loader(ctx))

  def plugins, do: [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]

  def middleware(middleware, _field, _object) do
    [ApolloTracing.Middleware.Tracing, ApolloTracing.Middleware.Caching] ++
      middleware ++ [Middlewares.ErrorHandler]
  end

  query do
    import_fields(:listing_queries)
    import_fields(:user_queries)
    import_fields(:dashboard_queries)
    import_fields(:interest_queries)
    import_fields(:calendar_queries)
    import_fields(:development_queries)
    import_fields(:tag_queries)
  end

  mutation do
    import_fields(:listing_mutations)
    import_fields(:image_mutations)
    import_fields(:user_mutations)
    import_fields(:interest_mutations)
    import_fields(:dashboard_mutations)
    import_fields(:calendar_mutations)
    import_fields(:development_mutations)
    import_fields(:unit_mutations)
    import_fields(:tag_mutations)
  end

  subscription do
    import_fields(:interest_subscriptions)
    import_fields(:listing_subscriptions)
    import_fields(:image_subscriptions)
    import_fields(:calendar_subscriptions)
  end

  defp loader(ctx) do
    default_params = default_params(ctx)

    Enum.reduce(
      sources(),
      Dataloader.new(),
      &Dataloader.add_source(&2, &1, :erlang.apply(&1, :data, [default_params]))
    )
  end

  defp default_params(%{current_user: current_user}), do: %{current_user: current_user}
  defp default_params(_), do: %{current_user: nil}

  defp sources do
    [
      Re.Accounts,
      Re.Addresses,
      Re.Developments,
      Re.Images,
      Re.Listings,
      Re.Listings.History.Prices,
      Re.Interests,
      Re.Interests.Types,
      Re.Favorites,
      Re.OwnerContacts,
      Re.Statistics.ListingVisualizations,
      Re.Statistics.TourVisualizations,
      Re.Statistics.InPersonVisits,
      Re.Tags,
      Re.Units
    ]
  end
end
