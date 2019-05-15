defmodule Re.Accounts do
  @moduledoc """
  Context boundary to Accounts management
  """

  alias Re.{
    Accounts.Queries,
    Repo,
    User
  }

  def data(params), do: Dataloader.Ecto.new(Repo, query: &query/2, default_params: params)

  def query(query, _args), do: query

  def paginated(params \\ %{}) do
    User
    |> Queries.or_contains_email(params)
    |> Queries.or_contains_name(params)
    |> Queries.or_contains_phone(params)
    |> Repo.paginate(params)
  end

  def change_role(user, role) do
    user
    |> User.update_changeset(%{role: role})
    |> Repo.update()
  end
end
