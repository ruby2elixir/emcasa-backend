defmodule Re.Users.Policy do
  @moduledoc """
  Policy module for user permission on users
  """

  alias Re.User

  def authorize(:favorited_listings, %User{}, _), do: :ok

  def authorize(_, nil, _), do: {:error, :unauthorized}

  def authorize(_, _, _), do: {:error, :forbidden}
end
