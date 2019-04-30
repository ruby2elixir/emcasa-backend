defmodule Re.Addresses.Policy do
  @moduledoc """
  Policy module for user permission on addresses
  """

  alias Re.User

  def authorize(:insert, %User{}, _), do: :ok

  def authorize(_, nil, _), do: {:error, :unauthorized}

  def authorize(_, _, _), do: {:error, :forbidden}
end
