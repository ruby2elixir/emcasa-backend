defmodule ReWeb.Resolvers.Users do
  @moduledoc """
  Resolver module for users queries and mutations
  """
  alias Re.Accounts.Users

  def favorited(_args, %{context: %{current_user: current_user}}) do
    {:ok, Users.favorited(current_user)}
  end
end
