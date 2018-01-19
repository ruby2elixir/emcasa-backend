defmodule Re.Accounts.Users do
  @moduledoc """
  Context boundary to User management
  """

  alias Re.{
    Repo,
    User
  }

  def get(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def get_by_email(email) do
    case Repo.get_by(User, email: String.downcase(email)) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def get_by_reset_token(token) do
    case Repo.get_by(User, reset_token: token) do
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

  def reset_password(user) do
    user
    |> User.reset_changeset(%{reset_token: UUID.uuid4()})
    |> Repo.update()
  end

  def redefine_password(user, password) do
    user
    |> User.redefine_changeset(%{password: password})
    |> Repo.update()
  end

  def edit_password(user, new_password) do
    user
    |> User.redefine_changeset(%{password: new_password})
    |> Repo.update()
  end
end
