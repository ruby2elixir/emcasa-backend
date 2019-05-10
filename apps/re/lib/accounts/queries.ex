defmodule Re.Accounts.Queries do
  alias Re.User
  import Ecto.Query, only: [from: 2]

  defp limit(query \\ User, _)

  defp limit(query, %{page_size: page_size}) do
    from(u in query, limit: ^page_size)
  end

  defp limit(query, _) do
    from(u in query, limit: 100)
  end

  defp offset(query, %{page_size: page_size, page: page}) do
    offset = (page - 1) * page_size
    from(u in query, offset: ^offset)
  end

  defp offset(query, _), do: query

  def build_query(params) do
    limit(params)
    |> offset(params)
  end
end
