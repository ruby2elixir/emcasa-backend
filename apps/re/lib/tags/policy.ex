defmodule Re.Tags.Policy do
  @moduledoc """
  Policy module for user permission on tags
  """

  alias Re.User

  def authorize(_, %User{role: "admin"}, _), do: :ok
  def authorize(_, nil, _), do: {:error, :unauthorize}
  def authorize(_, _, _), do: {:error, :forbidden}
end
