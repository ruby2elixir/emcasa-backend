defmodule ReIntegrations.Search do
  @moduledoc """
  Module to perform operations with elasticsearch
  """

  alias ReIntegrations.Search.Cluster

  @spec build_index() :: GenServer.cast()
  def build_index(), do: GenServer.cast(__MODULE__.Server, :build_index)

  @spec cleanup_index() :: GenServer.cast()
  def cleanup_index(), do: GenServer.cast(__MODULE__.Server, :cleanup_index)

  @query_fiels [
    "everything",
    "rooms^2",
    "bathrooms^2",
    "garage_spots^2",
    "restoorms^2",
    "suites^2",
    "dependencies^2",
    "balconies^2",
    "address^2"
  ]

  def post(query) do
    Elasticsearch.post(Cluster, "/listings/_search", %{
      "query" => %{
        "multi_match" => %{
          "query" => "#{query}",
          "fields" => @query_fiels,
          "fuzziness" => "AUTO"
        }
      }
    })
  end
end
