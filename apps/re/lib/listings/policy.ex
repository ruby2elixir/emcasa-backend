defmodule Re.Listings.Policy do
  @moduledoc """
  Policy module for user permission on listings
  """
  alias Re.User

  def authorize(_, %User{role: "admin"}, _), do: :ok
  def authorize(:show_listing, _, %{status: "active"}), do: :ok
  def authorize(:show_listing, %User{id: id}, %{user_id: id}), do: :ok
  def authorize(:show_listing, _, _), do: {:error, :not_found}

  def authorize(:per_user, %User{}, _), do: :ok

  def authorize(:show_stats, %User{id: id}, %{user_id: id}), do: :ok
  def authorize(:has_admin_rights, %User{id: id}, %{user_id: id}), do: :ok

  def authorize(_, nil, _), do: {:error, :unauthorized}

  def authorize(_, _, _), do: {:error, :forbidden}
end
