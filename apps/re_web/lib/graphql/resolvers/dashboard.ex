defmodule ReWeb.Resolvers.Dashboard do
  @moduledoc """
  Resolver module for admin dashboard
  """
  import Ecto.Query

  alias Re.{
    Listing,
    Listings.Admin,
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

  def active_listing_count(%{is_release: is_release}, _res) do
    {:ok,
     Repo.one(
       from(
         l in Re.Listing,
         where: l.status == "active" and l.is_release == ^is_release,
         select: count(l.id)
       )
     )}
  end

  def favorite_count(_params, _res) do
    {:ok, Repo.one(from(f in Re.Favorite, select: count(f.id)))}
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
