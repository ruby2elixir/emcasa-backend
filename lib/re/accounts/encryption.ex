defmodule Re.Accounts.Encryption do
  @moduledoc """
  Module for hashing logic
  """
  alias Comeonin.Bcrypt

  def password_hashing(password), do: Bcrypt.hashpwsalt(password)
  def validate_password(password, hash), do: Bcrypt.checkpw(password, hash)
end
