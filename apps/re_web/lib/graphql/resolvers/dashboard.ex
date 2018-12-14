defmodule ReWeb.Resolvers.Dashboard do
  @moduledoc """
  Resolver module for admin dashboard
  """
  import Ecto.Query

  alias Re.{
    Listing,
    Listings,
    Listings.Admin,
    Listings.Highlights,
    PriceSuggestions,
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

  def active_listing_count(_params, _res) do
    {:ok, Repo.one(from(l in Re.Listing, where: l.status == "active", select: count(l.id)))}
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

  def upload_factors_csv(%{factors: %Plug.Upload{path: path}}, %{
        context: %{current_user: current_user}
      }) do
    with :ok <- is_admin(current_user),
         {:ok, file_content} <- File.read(path) do
      PriceSuggestions.save_factors(file_content)

      {:ok, "ok"}
    end
  end

  def listing_zap_highlights(params, %{context: %{current_user: current_user}}) do
    with :ok <- is_admin(current_user),
         do: {:ok, Highlights.get_zap_highlights(params)}
  end

  def listing_zap_super_highlights(params, %{context: %{current_user: current_user}}) do
    with :ok <- is_admin(current_user),
         do: {:ok, Highlights.get_zap_super_highlights(params)}
  end

  def listing_vivareal_highlights(params, %{context: %{current_user: current_user}}) do
    with :ok <- is_admin(current_user),
         do: {:ok, Highlights.get_vivareal_highlights(params)}
  end

  def listing_highlight_zap(%{listing_id: listing_id}, %{context: %{current_user: current_user}}) do
    with :ok <- is_admin(current_user),
         {:ok, listing} <- Listings.get(listing_id),
         do: Highlights.insert_zap_highlight(listing)
  end

  def listing_super_highlight_zap(%{listing_id: listing_id}, %{
        context: %{current_user: current_user}
      }) do
    with :ok <- is_admin(current_user),
         {:ok, listing} <- Listings.get(listing_id),
         do: Highlights.insert_zap_super_highlight(listing)
  end

  def listing_highlight_vivareal(%{listing_id: listing_id}, %{
        context: %{current_user: current_user}
      }) do
    with :ok <- is_admin(current_user),
         {:ok, listing} <- Listings.get(listing_id),
         do: Highlights.insert_vivareal_highlight(listing)
  end

  defp is_admin(nil), do: {:error, :unauthorized}
  defp is_admin(%{role: "admin"}), do: :ok
  defp is_admin(_), do: {:error, :forbidden}
end
