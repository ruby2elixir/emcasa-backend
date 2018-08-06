defmodule ReWeb.Schema do
  @moduledoc """
  Module for defining graphQL schemas
  """
  use Absinthe.Schema

  import_types ReWeb.Types.{Listing, User, Message, Interest, Dashboard}

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
    import_fields(:message_queries)
    import_fields(:dashboard_queries)
    import_fields(:interest_queries)
  end

  mutation do
    import_fields(:listing_mutations)
    import_fields(:message_mutations)
    import_fields(:user_mutations)
    import_fields(:interest_mutations)
    import_fields(:dashboard_mutations)
  end

  subscription do
    import_fields(:interest_subscriptions)
    import_fields(:message_subscriptions)
    import_fields(:listing_subscriptions)
    import_fields(:user_subscriptions)
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
      Re.Images,
      Re.Listings,
      Re.Listings.PriceHistories,
      Re.Messages,
      Re.Interests,
      Re.Favorites,
      Re.Blacklists,
      Re.Stats.ListingVisualizations,
      Re.Stats.TourVisualizations,
      Re.Stats.InPersonVisits
    ]
  end
end
