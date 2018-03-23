defmodule Re.Listings.Policy do
  @moduledoc """
  Policy module for user permission on listings
  """

  alias Re.{
    Listing,
    User
  }

  def authorize(_, %User{role: "admin"}, _), do: :ok
  def authorize(:create_listing, %User{role: "user"}, _), do: :ok
  def authorize(:show_listing, _, %{is_active: true}), do: :ok
  def authorize(:show_listing, %User{id: id}, %{user_id: id}), do: :ok
  def authorize(:show_listing, _, _), do: {:error, :not_found}
  def authorize(:edit_listing, %User{id: id, role: "user"}, %Listing{user_id: id}), do: :ok
  def authorize(:update_listing, %User{id: id, role: "user"}, %Listing{user_id: id}), do: :ok
  def authorize(:delete_listing, %User{id: id, role: "user"}, %Listing{user_id: id}), do: :ok

  def authorize(:order_listing_images, %User{id: id, role: "user"}, %Listing{user_id: id}),
    do: :ok

  def authorize(:favorite_listing, %User{}, _), do: :ok
  def authorize(:unfavorite_listing, %User{}, _), do: :ok

  def authorize(_, nil, _), do: {:error, :unauthorized}

  def authorize(_, _, _), do: {:error, :forbidden}
end
