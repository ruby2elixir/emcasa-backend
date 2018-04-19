defmodule ReWeb.Resolvers.Messages do
  @moduledoc """
  Resolver module for messages
  """
  alias Re.{
    Users,
    Messages
  }

  def send(params, %{context: %{current_user: current_user}}) do
    Messages.send(current_user, params)
  end
end
