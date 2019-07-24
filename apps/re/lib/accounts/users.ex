defmodule Re.Accounts.Users do
  @moduledoc """
  Context boundary to User management
  """

  alias Ecto.Changeset

  alias Re.{
    Repo,
    User,
    Addresses.Neighborhoods
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

  def update(user, params, opts \\ []) do
    user
    |> Repo.preload(:districts)
    |> User.update_changeset(params)
    |> changeset_for_opts(opts)
    |> Repo.update()
  end

  defp changeset_for_opts(user_changeset, opts) do
    Enum.reduce(opts, user_changeset, fn
      {:districts, districts}, changeset ->
        repo_districts = Neighborhoods.districts_by_name_slugs(districts)
        Changeset.put_assoc(changeset, :districts, repo_districts)
    end)
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

  @garagem_url Application.get_env(:re, :garagem_url, "localhost")

  def build_user_url(%{id: id}) do
    @garagem_url
    |> URI.parse()
    |> URI.merge("/usuarios/#{id}")
    |> URI.to_string()
  end
end
