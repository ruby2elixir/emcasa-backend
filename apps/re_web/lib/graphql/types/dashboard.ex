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

  input_object :listing_zap_highlight do
    field :listing_id, non_null(:id)
    field :highlight, non_null(:boolean)
    field :super_highlight, non_null(:boolean)
  end

  input_object :listing_vivareal_highlight do
    field :listing_id, non_null(:id)
    field :highlight, non_null(:boolean)
  end

  object :dashboard_queries do
    @desc "Get dashboard stats"
    field :dashboard, :dashboard, resolve: &DashboardResolvers.index/2
  end

  object :dashboard_mutations do
    @desc "Upload file with price suggestion factors"
    field :upload_factors_csv, :string do
      arg :factors, non_null(:upload)

      resolve &DashboardResolvers.upload_factors_csv/2
    end

    @desc "Bulk highligh listing on zap"
    field :listing_highlight_zap, :listing do
      arg :input, list_of(:listing_zap_highlight)

      resolve &DashboardResolvers.listing_highlight_zap/2
    end

    @desc "Bulk highligh listing on vivareal"
    field :listing_highlight_vivareal, :listing do
      arg :input, list_of(:listing_vivareal_highlight)

      resolve &DashboardResolvers.listing_highlight_vivareal/2
    end
  end
end
