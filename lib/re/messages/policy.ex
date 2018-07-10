defmodule Re.Messages.Policy do
  @moduledoc """
  Policy module for user permission on messages
  """

  alias Re.User

  def authorize(:mark_as_read, %User{id: id}, %{receiver_id: id}), do: :ok
  def authorize(:mark_as_read, _, _), do: {:error, :forbidden}

  def authorize(_, %User{role: "admin"}, _), do: :ok

  def authorize(:send_message, %User{}, _), do: :ok
  def authorize(:index, %User{}, _), do: :ok

  def authorize(_, nil, _), do: {:error, :unauthorized}

  def authorize(_, _, _), do: {:error, :forbidden}
end
