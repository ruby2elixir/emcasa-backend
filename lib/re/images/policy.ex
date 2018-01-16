defmodule Re.Images.Policy do
  @moduledoc """
  Policy module for user permission on images
  """

  alias Re.{
    Listing,
    User
  }

  def authorize(_, %{role: "admin"}, _), do: :ok
  def authorize(_, nil, _), do: {:error, :unauthorized}
  def authorize(:index_images, %User{id: id, role: "user"}, %Listing{user_id: id}), do: :ok
  def authorize(:create_images, %User{id: id, role: "user"}, %Listing{user_id: id}), do: :ok
  def authorize(:delete_images, %User{id: id, role: "user"}, %Listing{user_id: id}), do: :ok

  def authorize(_, _, _), do: {:error, :forbidden}

end
