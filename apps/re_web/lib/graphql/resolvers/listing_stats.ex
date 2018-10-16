defmodule ReWeb.Resolvers.ListingStats do
  @moduledoc """
  Resolver module for listing queries and mutations
  """
  alias Re.Listings

  alias Re.Statistics.Visualizations

  @visualizations Application.get_env(:re, :visualizations, Visualizations)

  def tour_visualized(%{id: id}, %{context: %{current_user: current_user, details: details}}) do
    with {:ok, listing} <- Listings.get(id) do
      {@visualizations.tour(
         listing,
         current_user,
         "matterport_code:#{listing.matterport_code};#{details}"
       ), listing}
    end
  end
end
