defmodule ReWeb.SearchController do
  use ReWeb, :controller
  use ReWeb.GuardedController

  alias ReWeb.Search.Cluster

  action_fallback(ReWeb.FallbackController)

  def index(conn, %{"q" => query}, _user) do

    {:ok, results} = Elasticsearch.post(
      Cluster,
      "/listings/_doc/_search",
      %{"query" =>
        %{"multi_match" =>
          %{"query" => "#{query}",
            "fields" => ["description", "neighborhood"],
            "fuzziness" => "AUTO"
    }}})

    render(conn, ReWeb.SearchView, "search.json", results: results)
  end
end
