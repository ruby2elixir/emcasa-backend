defmodule ReWeb.Types.Dashboard do
  @moduledoc """
  GraphQL types for dashboard
  """
  use Absinthe.Schema.Notation

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
end
