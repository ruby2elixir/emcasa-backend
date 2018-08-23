defmodule ReWeb.AbsintheHelpers do
  @moduledoc """
  Helpers for absinthe endpoint testing
  """
  def query_skeleton(query, query_name) do
    %{
      "operationName" => "#{query_name}",
      "query" => "query #{query_name} #{query}",
      "variables" => "{}"
    }
  end

  def query_wrapper(query, variables \\ %{}) do
    %{
      "query" => query,
      "variables" => variables
    }
  end

  def mutation_skeleton(query) do
    %{
      "operationName" => "",
      "query" => "#{query}",
      "variables" => ""
    }
  end

  def mutation_wrapper(query, variables \\ %{}) do
    %{
      "query" => "#{query}",
      "variables" => variables
    }
  end
end
