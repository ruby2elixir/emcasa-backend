defmodule ReWeb.SearchController do
  use ReWeb, :controller
  use ReWeb.GuardedController

  alias ReWeb.Search.Cluster

  action_fallback(ReWeb.FallbackController)

  def index(conn, %{"q" => query}, _user) do
    {:ok, results} =
      Elasticsearch.post(Cluster, "/listings/_search", %{
        "query" => %{
          "multi_match" => %{
            "query" => "#{query}",
            "fields" => ["everything"],
            "fuzziness" => "AUTO"
          }
        }
      }) |> IO.inspect

    render(conn, ReWeb.SearchView, "search.json", results: results)
  end
end
