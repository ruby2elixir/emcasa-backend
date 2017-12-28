defmodule ReWeb.NeighborhoodView do
  use ReWeb, :view

  def render("index.json", %{neighborhoods: neighborhoods}) do
    %{neighborhoods: render_many(neighborhoods, ReWeb.NeighborhooView, "neighborhood.json")}
  end

  def render("neighborhood.json", %{neighborhood: neighborhood}) do
    %{id: neighborhood.id,
    }
  end
end
