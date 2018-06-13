defmodule Re.Accounts.DataloaderQueries do
  @moduledoc """
  Module for grouping accounts queries
  """
  import Ecto.Query

  def build(query, args) do
    query
    |> common_queries(args)
    |> queries_by_role(args)
  end

  defp common_queries(query, args) do
    args
    |> Enum.reduce(query, &common_query/2)
    |> order_by([i], asc: i.position)
  end

  defp common_query({:limit, limit}, q), do: limit(q, ^limit)

  defp common_query(_, q), do: q

  defp queries_by_role(query, %{has_admin_rights: true} = args) do
    Enum.reduce(args, query, &admin_query/2)
  end

  defp queries_by_role(query, %{has_admin_rights: false}) do
    where(query, [i], i.is_active == true)
  end

  defp admin_query({:is_active, is_active}, q), do: where(q, [i], i.is_active == ^is_active)

  defp admin_query(_, q), do: q
end
