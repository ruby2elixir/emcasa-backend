defmodule Re.Accounts.Users do
  @moduledoc """
  Context boundary to User management
  """

  alias Re.{
    Repo,
    User
  }

  defdelegate authorize(action, user, params), to: Re.Users.Policy

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

  def get_by_phone(phone) do
    case Repo.get_by(User, phone: phone) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def get_by_uuid(uuid) do
    case Repo.get_by(User, uuid: uuid) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def update(user, params) do
    user
    |> User.update_changeset(params)
    |> Repo.update()
  end

  def change_email(user, new_email) do
    user
    |> User.update_changeset(%{email: new_email})
    |> Repo.update()
  end

  def favorited(user) do
    user
    |> Repo.preload(favorited: [:images])
    |> Map.get(:favorited)
  end
end
