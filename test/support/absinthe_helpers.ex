defmodule ReWeb.AbsintheHelpers do
  @moduledoc """
  Helpers for absinthe endpoint testing
  """
  def query_wrapper(query, variables \\ %{}) do
    %{
      "query" => query,
      "variables" => variables
    }
  end

  def mutation_wrapper(query, variables \\ %{}) do
    %{
      "query" => "#{query}",
      "variables" => variables
    }
  end
end
