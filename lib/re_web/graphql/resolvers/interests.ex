defmodule ReWeb.Resolvers.Interests do
  @moduledoc """
  Resolver module for interests queries and mutations
  """
  alias Re.Interests

  def request_contact(params, %{context: %{current_user: current_user}}) do
    Interests.request_contact(params, current_user)
  end
end
