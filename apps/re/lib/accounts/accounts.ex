defmodule Re.Accounts do
  @moduledoc """
  Context boundary to Accounts management
  """

  import Ecto.Query, only: [from: 1]

  alias Re.{
    Accounts.Queries,
    Repo,
    User
  }

  def data(params), do: Dataloader.Ecto.new(Repo, query: &query/2, default_params: params)

  def query(query, _args), do: query

  def paginated(params) do
    pagination = Map.get(params, :pagination, %{})

    from(u in Re.User)
    |> Repo.paginate(pagination)
  end

  def promote_user_to_admin(user) do
    user
    |> User.update_changeset(%{role: "admin"})
    |> Repo.update()
  end
end
