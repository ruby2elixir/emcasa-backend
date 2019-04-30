defmodule Re.Addresses.Policy do
  @moduledoc """
  Policy module for user permission on addresses
  """

  alias Re.{
    Listing,
    User
  }

  def authorize(_, %User{role: "admin"}, _), do: :ok
  def authorize(:insert, %User{}, _), do: :ok
  def authorize(:show_complete_address, %User{id: id}, %Listing{user_id: id}), do: :ok

  def authorize(_, nil, _), do: {:error, :unauthorized}

  def authorize(_, _, _), do: {:error, :forbidden}
end
