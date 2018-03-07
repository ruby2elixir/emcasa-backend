defmodule ReWeb.InterestTypeController do
  use ReWeb, :controller

  alias Re.Listings.Interests

  action_fallback(ReWeb.FallbackController)

  def index(conn, _params) do
    render(conn, "index.json", interest_types: Interests.get_types())
  end
end
