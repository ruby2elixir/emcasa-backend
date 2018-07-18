defmodule Re.Messages.DataloaderQueries do
  @moduledoc """
  Module for grouping messages queries
  """
  import Ecto.Query

  def build(query, args) do
    query
    |> unread_only(args)
    |> order_by([m], desc: m.inserted_at)
  end

  defp unread_only(query, %{read: read, current_user: %{id: user_id}}) do
    where(query, [m], m.read == ^read and m.receiver_id == ^user_id)
  end

  defp unread_only(query, _), do: query
end
