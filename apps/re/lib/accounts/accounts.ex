defmodule Re.Accounts do
  @moduledoc """
  Context boundary to Accounts management
  """

  alias Re.{
    Accounts.Users,
    Repo,
    User
  }

  import Ecto.Query

  def data(params), do: Dataloader.Ecto.new(Repo, query: &query/2, default_params: params)

  def query(query, _args), do: query

  defp build_query(params) do
    limit(params)
    |> offset_user(params)
  end

  defp limit(query // User, %{page_size: page_size}) do
    from(u in query, limit: ^page_size)
  end

  defp limit(query // User, _) do
    from(u in query, limit: 100)
  end

  defp offset_user(query // User, %{page_size: page_size, page: page}) do
    offset = (page - 1) * page_size
    offset(u in query, offset: ^offset)
  end

  defp offset_user(query // User, _), do: query

  def all(params) do
    build_query(params)
    |> Repo.all()
  end

  def promote_user_to_admin(phone) do
    case Users.get_by_phone(phone) do
      {:ok, user} ->
        user
        |> User.update_changeset(%{role: "admin"})
        |> Repo.update()

      error ->
        error
    end
  end
end
