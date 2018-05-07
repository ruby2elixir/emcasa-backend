defmodule ReWeb.Resolvers.Users do
  @moduledoc """
  Resolver module for users queries and mutations
  """
  alias Re.Accounts.Users

  def favorited(_args, %{context: %{current_user: current_user}}) do
    case Bodyguard.permit(Users, :favorited_listings, current_user, %{}) do
      :ok -> {:ok, Users.favorited(current_user)}
      error -> error
    end
  end

  def profile(%{id: id}, %{context: %{current_user: current_user}}) do
    with {:ok, user} <- Users.get(id),
         :ok <- Bodyguard.permit(Users, :show_profile, current_user, user),
         do: {:ok, user}
  end

  def edit_profile(%{id: id} = params, %{context: %{current_user: current_user}}) do
    with {:ok, user} <- Users.get(id),
         :ok <- Bodyguard.permit(Users, :edit_profile, current_user, user),
         do: Users.update(user, params)
  end
end
