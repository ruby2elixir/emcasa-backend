defmodule Re.Images.DataloaderQueries do
  @moduledoc """
  Module for grouping images queries
  """
  import Ecto.Query

  def build(query, %{has_admin_rights: true} = args), do: Enum.reduce(args, query, &admin_query/2)

  def build(query, _args), do: user_query(query)

  defp admin_query({:is_active, is_active}, q), do: where(q, [i], i.is_active == ^is_active)

  defp admin_query(_, q), do: q

  def user_query(q), do: where(q, [i], i.is_active == true)
end
