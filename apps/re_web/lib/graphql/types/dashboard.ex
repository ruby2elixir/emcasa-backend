defmodule ReWeb.Types.Dashboard do
  @moduledoc """
  GraphQL types for dashboard
  """
  use Absinthe.Schema.Notation

  import_types Absinthe.Plug.Types

  alias ReWeb.Resolvers.Dashboard, as: DashboardResolvers

  object :dashboard do
    field :active_listing_count, :integer, resolve: &DashboardResolvers.active_listing_count/2
    field :favorite_count, :integer, resolve: &DashboardResolvers.favorite_count/2
    field :visualization_count, :integer, resolve: &DashboardResolvers.visualization_count/2

    field :tour_visualization_count, :integer,
      resolve: &DashboardResolvers.tour_visualization_count/2

    field :maintenance_fee_count, :integer, resolve: &DashboardResolvers.maintenance_fee_count/2
    field :property_tax_count, :integer, resolve: &DashboardResolvers.property_tax_count/2
    field :tour_count, :integer, resolve: &DashboardResolvers.tour_count/2
    field :area_count, :integer, resolve: &DashboardResolvers.area_count/2
  end

  object :dashboard_queries do
    @desc "Get dashboard stats"
    field :dashboard, :dashboard, resolve: &DashboardResolvers.index/2

    @desc "Get zap highlights"
    field :listing_zap_highlights, list_of(:listing) do
      resolve &DashboardResolvers.listing_zap_highlights/2
    end

    @desc "Get zap super highlights"
    field :listing_zap_super_highlights, list_of(:listing) do
      resolve &DashboardResolvers.listing_zap_super_highlights/2
    end

    @desc "Get vivareal highlights"
    field :listing_vivareal_highlights, list_of(:listing) do
      resolve &DashboardResolvers.listing_vivareal_highlights/2
    end
  end

  object :dashboard_mutations do
    @desc "Upload file with price suggestion factors"
    field :upload_factors_csv, :string do
      arg :factors, non_null(:upload)

      resolve &DashboardResolvers.upload_factors_csv/2
    end

    @desc "Highligh listing on zap"
    field :listing_highlight_zap, :listing do
      arg :listing_id, non_null(:id)

      resolve &DashboardResolvers.listing_highlight_zap/2
    end

    @desc "Super highligh listing on zap"
    field :listing_super_highlight_zap, :listing do
      arg :listing_id, non_null(:id)

      resolve &DashboardResolvers.listing_super_highlight_zap/2
    end

    @desc "Highligh listing on vivareal"
    field :listing_highlight_vivareal, :listing do
      arg :listing_id, non_null(:id)

      resolve &DashboardResolvers.listing_highlight_vivareal/2
    end
  end

  object :dashboard_subscriptions do
    @desc "Subscribe to zap listing highlits"
    field :listing_highlighted_zap, :listing do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          %{role: "admin"} -> {:ok, topic: "listing_highlighted_zap"}
          %{} -> {:error, :unauthorized}
          _ -> {:error, :unauthenticated}
        end
      end)

      trigger :listing_highlight_zap,
        topic: fn _ -> "listing_highlighted_zap" end
    end

    @desc "Subscribe to zap listing super highlits"
    field :listing_super_highlighted_zap, :listing do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          %{role: "admin"} -> {:ok, topic: "listing_super_highlighted_zap"}
          %{} -> {:error, :unauthorized}
          _ -> {:error, :unauthenticated}
        end
      end)

      trigger :listing_super_highlight_zap,
        topic: fn _ -> "listing_super_highlighted_zap" end
    end

    @desc "Subscribe to vivareal listing highlits"
    field :listing_highlighted_vivareal, :listing do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          %{role: "admin"} -> {:ok, topic: "listing_highlighted_vivareal"}
          %{} -> {:error, :unauthorized}
          _ -> {:error, :unauthenticated}
        end
      end)

      trigger :listing_highlight_zap,
        topic: fn _ -> "listing_highlighted_vivareal" end
    end
  end
end
