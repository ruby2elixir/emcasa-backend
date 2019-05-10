defmodule Re.Accounts do
  @moduledoc """
  Context boundary to Accounts management
  """

  alias Re.{
    Repo,
    User
  }

  def data(params), do: Dataloader.Ecto.new(Repo, query: &query/2, default_params: params)

  def query(query, _args), do: query

  def get_by_uuid(uuid) do
    case Repo.get_by(User, uuid: uuid) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def promote_user_to_admin(user) do
    user
    |> User.update_changeset(%{role: "admin"})
    |> Repo.update()
  end
end
