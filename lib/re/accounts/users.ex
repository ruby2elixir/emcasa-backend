defmodule Re.Accounts.Users do
  @moduledoc """
  Context boundary to User management
  """

  alias Re.{
    Repo,
    User
  }

  def get_by_email(email) do
    case Repo.get_by(User, email: String.downcase(email)) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def create(params) do
    params = Map.put(params, "role", "user")

    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end

end
