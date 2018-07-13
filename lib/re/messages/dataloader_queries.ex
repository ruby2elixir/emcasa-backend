defmodule Re.Messages.DataloaderQueries do
  @moduledoc """
  Module for grouping messages queries
  """
  import Ecto.Query

  def build(query, args), do: Enum.reduce(args, query, &build_query/2)

  defp build_query({:limit, limit}, query), do: limit(query, ^limit)

  defp build_query({:offset, offset}, query), do: offset(query, ^offset)

  defp build_query({:read, read}, query), do: where(query, [m], m.read == ^read)

  defp build_query(_, query), do: query
end
