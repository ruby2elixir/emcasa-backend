defmodule ReWeb.NeighborhoodController do
  use ReWeb, :controller

  alias Re.Addresses

  def index(conn, _params) do
    render(conn, "index.json", neighborhoods: Neighborhoods.all())
  end
end
