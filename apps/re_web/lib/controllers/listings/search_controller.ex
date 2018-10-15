defmodule ReWeb.SearchController do
  use ReWeb, :controller
  use ReWeb.GuardedController

  action_fallback(ReWeb.FallbackController)

  def index(conn, %{"q" => query}, _user) do
    {:ok, results} = ReIntegrations.Search.post(query)

    render(conn, ReWeb.SearchView, "search.json", results: results)
  end
end
