defmodule ReWeb.SearchController do
  use ReWeb, :controller
  use ReWeb.GuardedController

  alias ReWeb.Search.Cluster

  action_fallback(ReWeb.FallbackController)

  @query_fiels [
    "everything",
    "rooms^2",
    "bathrooms^2",
    "garage_spots^2",
    "restoorms^2",
    "suites^2",
    "dependencies^2",
    "balconies^2",
    "address^2""
  ]

  def index(conn, %{"q" => query}, _user) do
    {:ok, results} =
      Elasticsearch.post(Cluster, "/listings/_search", %{
        "query" => %{
          "multi_match" => %{
            "query" => "#{query}",
            "fields" => @query_fiels,
            "fuzziness" => "AUTO"
          }
        }
      })

    render(conn, ReWeb.SearchView, "search.json", results: results)
  end
end
