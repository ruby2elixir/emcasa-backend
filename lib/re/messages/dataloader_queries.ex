defmodule Re.Messages.DataloaderQueries do
  @moduledoc """
  Module for grouping messages queries
  """
  import Ecto.Query

  def build(query, args) do
    args
    |> Enum.reduce(query, &build_query/2)
    |> order_by([m], desc: m.inserted_at)
  end

  defp build_query({:read, read}, query), do: where(query, [m], m.read == ^read)

  defp build_query(_, query), do: query
end
