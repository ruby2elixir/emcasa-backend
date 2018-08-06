defmodule Re.Accounts.Users do
  @moduledoc """
  Context boundary to User management
  """

  alias Re.{
    Repo,
    User
  }

  alias Ecto.Changeset

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

  def get_by_reset_token(token) do
    case Repo.get_by(User, reset_token: token) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def create(params) do
    %User{}
    |> Changeset.change(role: "user")
    |> Changeset.change(confirmation_token: UUID.uuid4())
    |> Changeset.change(confirmed: false)
    |> Changeset.change(notification_preferences: %{})
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
    |> User.redefine_changeset(%{password: password, reset_token: nil})
    |> Repo.update()
  end

  def edit_password(user, new_password) do
    user
    |> User.redefine_changeset(%{password: new_password})
    |> Repo.update()
  end

  def change_email(user, new_email) do
    user
    |> User.email_changeset(%{
      email: new_email,
      confirmed: false,
      confirmation_token: UUID.uuid4()
    })
    |> Repo.update()
  end

  def favorited(user) do
    user
    |> Repo.preload(favorited: [:images])
    |> Map.get(:favorited)
  end
end
