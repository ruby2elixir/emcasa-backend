defmodule Re.Blacklists.Policy do
  @moduledoc """
  Policy module for user permission on blacklisting
  """

  alias Re.User

  def authorize(_, %User{role: "admin"}, _), do: :ok

  def authorize(:blacklist_listing, %User{}, _), do: :ok
  def authorize(:unblacklist_listing, %User{}, _), do: :ok

  def authorize(_, nil, _), do: {:error, :unauthorized}

  def authorize(_, _, _), do: {:error, :forbidden}
end
