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
    params =
      params
      |> Map.put("role", "user")
      |> Map.put("confirmation_token", UUID.uuid4())
      |> Map.put("confirmed", false)

    %User{}
    |> User.create_changeset(params)
    |> Repo.insert()
  end

  def confirm(token) do
    case Repo.get_by(User, confirmation_token: token) do
      nil -> {:error, :bad_request}
      user -> update(user, %{confirmed: true})
    end
  end

  def update(user, params) do
    user
    |> User.update_changeset(params)
    |> Repo.update()
  end
end
