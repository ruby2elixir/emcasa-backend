defmodule Re.Accounts.Auth do
  @moduledoc """
  The boundary for the Auth system
  """


  alias Re.Accounts.Users
  alias Comeonin.Bcrypt

  def find_user(email) do
    case Users.get_by_email(email) do
      {:ok, user} -> {:ok, user}
      {:error, :not_found} -> {:error, :unauthorized}
    end
  end

  def check_password(password, %{password: password_hash}) do
    if Bcrypt.checkpw(password, password_hash) do
      :ok
    else
      {:error, :unauthorized}
    end
  end

end
