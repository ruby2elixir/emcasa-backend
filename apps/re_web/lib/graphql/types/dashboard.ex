defmodule ReWeb.Types.Dashboard do
  @moduledoc """
  GraphQL types for dashboard
  """
  use Absinthe.Schema.Notation

  import_types Absinthe.Plug.Types

  alias ReWeb.Resolvers.Dashboard, as: DashboardResolvers

  object :dashboard do
    field :active_listing_count, :integer do
      arg :filters, :listing_filter_input

      resolve &DashboardResolvers.active_listing_count/2
    end

    field :favorite_count, :integer, resolve: &DashboardResolvers.favorite_count/2
    field :visualization_count, :integer, resolve: &DashboardResolvers.visualization_count/2

    field :tour_visualization_count, :integer,
      resolve: &DashboardResolvers.tour_visualization_count/2

    field :maintenance_fee_count, :integer, resolve: &DashboardResolvers.maintenance_fee_count/2
    field :property_tax_count, :integer, resolve: &DashboardResolvers.property_tax_count/2
    field :tour_count, :integer, resolve: &DashboardResolvers.tour_count/2
    field :area_count, :integer, resolve: &DashboardResolvers.area_count/2

    field :listings, :listing_pagination_admin do
      arg :pagination, :listing_pagination_admin_input
      arg :filters, :listing_filter_input
      arg :order_by, list_of(:order_by)

      resolve &DashboardResolvers.listings/2
    end
  end

  input_object :listing_pagination_admin_input do
    field :page, :integer
    field :page_size, :integer
  end

  object :listing_pagination_admin do
    field :entries, list_of(:listing)
    field :page_number, :integer
    field :page_size, :integer
    field :total_pages, :integer
    field :total_entries, :integer
  end

  object :dashboard_queries do
    @desc "Get dashboard stats"
    field :dashboard, :dashboard, resolve: &DashboardResolvers.index/2
  end

  object :dashboard_mutations do
    @desc "Upload file with price suggestion factors"
    field :upload_factors_csv, :string do
      deprecate("not used anymore")
      arg :factors, non_null(:upload)

      resolve &DashboardResolvers.upload_factors_csv/2
    end
  end
end
