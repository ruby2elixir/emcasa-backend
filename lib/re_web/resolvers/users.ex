defmodule ReWeb.Resolvers.Users do
  @moduledoc """
  Resolver module for users queries and mutations
  """
  alias Re.Accounts.Users

  def favorited(_args, %{context: %{current_user: current_user}}) do
    case Bodyguard.permit(Users, :favorited_listings, current_user) do
      :ok -> {:ok, Users.favorited(current_user)}
      error -> error
    end
  end
end
