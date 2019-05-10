defmodule Re.Accounts do
  @moduledoc """
  Context boundary to Accounts management
  """

  alias Re.{
    Accounts.Users,
    Repo,
    User
  }

  def data(params), do: Dataloader.Ecto.new(Repo, query: &query/2, default_params: params)

  def query(query, _args), do: query

  def change_role(user, new_role) do
    user
    |> User.update_changeset(%{role: new_role})
    |> Repo.update()
  end

  def get_by_uuid(uuid) do
    case Repo.get_by(User, uuid: uuid) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
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
