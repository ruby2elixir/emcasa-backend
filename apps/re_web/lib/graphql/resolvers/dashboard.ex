defmodule ReWeb.Resolvers.Dashboard do
  @moduledoc """
  Resolver module for admin dashboard
  """
  import Ecto.Query

  alias Re.{
    Listing,
    Listings.Admin,
    Listings.Filters,
    Repo
  }

  def index(_params, %{context: %{current_user: current_user}}) do
    with :ok <- is_admin(current_user) do
      {:ok, %{}}
    end
  end

  def listings(params, _) do
    {:ok, Admin.listings(params)}
  end

  def active_listing_count(%{filters: filters}, _res) do
    count =
      Re.Listing
      |> Filters.apply(Map.drop(filters, ["status", :status]))
      |> exclude(:distinct)
      |> where([l], l.status == "active")
      |> select([l], count(l.id))
      |> Repo.one()

    {:ok, count}
  end

  def active_listing_count(_params, _res) do
    {:ok,
     Repo.one(
       from(
         l in Re.Listing,
         select: count(l.id),
         where: l.status == "active"
       )
     )}
  end

  def favorite_count(_params, _res) do
    {:ok, Repo.one(from(f in Re.Favorite, select: count(f.id)))}
  end

  def visualization_count(_params, _res) do
    {:ok, Repo.one(from(lv in Re.Statistics.ListingVisualization, select: count(lv.id)))}
  end

  def tour_visualization_count(_params, _res) do
    {:ok, Repo.one(from(tv in Re.Statistics.TourVisualization, select: count(tv.id)))}
  end

  def maintenance_fee_count(_params, _res) do
    {:ok,
     Repo.one(
       from(
         l in Listing,
         where: not is_nil(l.maintenance_fee) and l.status == "active",
         select: count(l.id)
       )
     )}
  end

  def property_tax_count(_params, _res) do
    {:ok,
     Repo.one(
       from(
         l in Listing,
         where: not is_nil(l.property_tax) and l.status == "active",
         select: count(l.id)
       )
     )}
  end

  def tour_count(_params, _res) do
    {:ok,
     Repo.one(
       from(
         l in Listing,
         where: not is_nil(l.matterport_code) and l.status == "active",
         select: count(l.id)
       )
     )}
  end

  def area_count(_params, _res) do
    {:ok,
     Repo.one(
       from(l in Listing, where: not is_nil(l.area) and l.status == "active", select: count(l.id))
     )}
  end

  def upload_factors_csv(_, _), do: {:ok, "ok"}

  defp is_admin(nil), do: {:error, :unauthorized}
  defp is_admin(%{role: "admin"}), do: :ok
  defp is_admin(_), do: {:error, :forbidden}
end
