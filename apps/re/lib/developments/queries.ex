defmodule Re.Developments.Queries do
  @moduledoc """
  Module for grouping develpments queries
  """

  alias Re.Development

  import Ecto.Query

  def preload_relations(query \\ Development, relations \\ [])

  def preload_relations(query, relations), do: preload(query, ^relations)
end
