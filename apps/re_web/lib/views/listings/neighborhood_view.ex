defmodule ReWeb.NeighborhoodView do
  use ReWeb, :view

  def render("index.json", %{neighborhoods: neighborhoods}) do
    %{neighborhoods: render_many(neighborhoods, ReWeb.NeighborhoodView, "neighborhood.json")}
  end

  def render("neighborhood.json", %{neighborhood: neighborhood}) do
    neighborhood
  end
end
