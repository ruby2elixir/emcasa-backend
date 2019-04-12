defmodule Re.Tags.DataloaderQueries do
  @moduledoc """
  Module for grouping tags queries
  """
  import Ecto.Query

  def build(query, %{user: %{role: "admin"}}), do: query

  def build(query, _), do: where(query, [t], t.visibility == "public")
end
