defmodule Re.Accounts.Auth do
  @moduledoc """
  The boundary for the Auth system
  """

  alias Re.{
    User,
    Accounts.Users,
    Repo
  }

  alias Comeonin.Bcrypt

  @account_kit Application.get_env(:re, :account_kit, AccountKit)

  def find_user(email) do
    case Users.get_by_email(email) do
      {:ok, user} -> {:ok, user}
      {:error, :not_found} -> {:error, :unauthorized}
    end
  end

  def check_password(password, %{password_hash: password_hash}) do
    if Bcrypt.checkpw(password, password_hash) do
      :ok
    else
      {:error, :unauthorized}
    end
  end

  def account_kit_sign_in(access_token) do
    with {:ok, payload} <- @account_kit.me(access_token),
         :ok <- valid_application_id?(payload) do
      get_user(payload)
    end
  end

  defp valid_application_id?(%{"application" => %{"id" => application_id}}) do
    if Application.get_env(:account_kit, :app_id) == application_id do
      :ok
    else
      {:error, :application_id_doesnt_match}
    end
  end

  defp get_user(%{"id" => account_kit_id, "phone" => %{"number" => phone}}) do
    case Repo.get_by(User, account_kit_id: account_kit_id) do
      nil -> create_user(%{account_kit_id: account_kit_id, phone: phone})
      user -> {:ok, user}
    end
  end

  defp create_user(params) do
    %User{}
    |> User.account_kit_changeset(params)
    |> Repo.insert()
  end
end
