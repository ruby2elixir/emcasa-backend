defmodule ReWeb.Resolvers.Channels do
  @moduledoc """
  Resolver module for channels
  """
  alias Re.Messages.Channels

  def get(_, %{context: %{current_user: current_user}}) do
    {:ok, Channels.all(current_user)}
  end
end
