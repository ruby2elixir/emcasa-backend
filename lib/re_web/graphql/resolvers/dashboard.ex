defmodule ReWeb.Resolvers.Dashboard do
  @moduledoc """
  Resolver module for admin dashboard
  """
  import Ecto.Query

  alias Re.{
    Listing,
    Repo
  }

  def index(_params, %{context: %{current_user: %{role: "admin"}}}) do
    {:ok, %{}}
  end

  def index(_params, %{context: %{current_user: nil}}), do: {:error, :unautenticated}
  def index(_params, _res), do: {:error, :forbidden}

  def active_listing_count(_params, _res) do
    {:ok, Repo.one(from(l in Re.Listing, where: l.is_active == true, select: count(l.id)))}
  end

  def favorite_count(_params, _res) do
    {:ok, Repo.one(from(f in Re.Favorite, select: count(f.id)))}
  end

  def visualization_count(_params, _res) do
    {:ok, Repo.one(from(lv in Re.Stats.ListingVisualization, select: count(lv.id)))}
  end

  def tour_visualization_count(_params, _res) do
    {:ok, Repo.one(from(tv in Re.Stats.TourVisualization, select: count(tv.id)))}
  end

  def maintenance_fee_count(_params, _res) do
    {:ok,
     Repo.one(
       from(
         l in Listing,
         where: not is_nil(l.maintenance_fee) and l.is_active == true,
         select: count(l.id)
       )
     )}
  end

  def property_tax_count(_params, _res) do
    {:ok,
     Repo.one(
       from(
         l in Listing,
         where: not is_nil(l.property_tax) and l.is_active == true,
         select: count(l.id)
       )
     )}
  end

  def tour_count(_params, _res) do
    {:ok,
     Repo.one(
       from(
         l in Listing,
         where: not is_nil(l.matterport_code) and l.is_active == true,
         select: count(l.id)
       )
     )}
  end

  def area_count(_params, _res) do
    {:ok,
     Repo.one(
       from(l in Listing, where: not is_nil(l.area) and l.is_active == true, select: count(l.id))
     )}
  end
end
