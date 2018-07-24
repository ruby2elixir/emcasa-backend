defmodule ReWeb.Resolvers.Interests do
  @moduledoc """
  Resolver module for interests queries and mutations
  """
  alias Re.Interests

  def request_contact(params, %{context: %{current_user: current_user}}) do
    Interests.request_contact(params, current_user)
  end

  def request_price_suggestion(params, %{context: %{current_user: current_user}}) do
    Interests.request_price_suggestion(params, current_user)
  end
end
