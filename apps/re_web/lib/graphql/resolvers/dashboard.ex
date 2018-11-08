defmodule ReWeb.Resolvers.Dashboard do
  @moduledoc """
  Resolver module for admin dashboard
  """
  import Ecto.Query

  alias Re.{
    Listing,
    Listings,
    Listings.Highlights,
    PriceSuggestions,
    Repo
  }

  def index(_params, %{context: %{current_user: current_user}}) do
    with :ok <- is_admin(current_user) do
      {:ok, %{}}
    end
  end

  def active_listing_count(_params, _res) do
    {:ok, Repo.one(from(l in Re.Listing, where: l.is_active == true, select: count(l.id)))}
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

  def upload_factors_csv(%{factors: %Plug.Upload{path: path}}, %{
        context: %{current_user: current_user}
      }) do
    with :ok <- is_admin(current_user),
         {:ok, file_content} <- File.read(path) do
      PriceSuggestions.save_factors(file_content)

      {:ok, "ok"}
    end
  end

  def listing_zap_highlights(_, %{context: %{current_user: current_user}}) do
    with :ok <- is_admin(current_user),
      do: {:ok, Highlights.get_zap_highlights()}
  end

  def listing_zap_super_highlights(_, %{context: %{current_user: current_user}}) do
    with :ok <- is_admin(current_user),
      do: {:ok, Highlights.get_zap_super_highlights()}
  end

  def listing_vivareal_highlights(_, %{context: %{current_user: current_user}}) do
    with :ok <- is_admin(current_user),
      do: {:ok, Highlights.get_vivareal_highlights()}
  end

  def listing_highlight_zap(%{listing_id: listing_id}, %{context: %{current_user: current_user}}) do
    with :ok <- is_admin(current_user),
         {:ok, listing} <- Listings.get(listing_id),
         {:ok, _highlight} <- Highlights.insert_zap_highlight(listing),
      do: {:ok, listing}
  end

  def listing_super_highlight_zap(%{listing_id: listing_id}, %{context: %{current_user: current_user}}) do
    with :ok <- is_admin(current_user),
         {:ok, listing} <- Listings.get(listing_id),
         {:ok, _highlight} <- Highlights.insert_zap_super_highlight(listing),
      do: {:ok, listing}
  end

  def listing_highlight_vivareal(%{listing_id: listing_id}, %{context: %{current_user: current_user}}) do
    with :ok <- is_admin(current_user),
         {:ok, listing} <- Listings.get(listing_id),
         {:ok, _highlight} <- Highlights.insert_vivareal_highlight(listing),
      do: {:ok, listing}
  end

  defp is_admin(nil), do: {:error, :unauthorized}
  defp is_admin(%{role: "admin"}), do: :ok
  defp is_admin(_), do: {:error, :forbidden}
end
