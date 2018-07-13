defmodule ReWeb.Resolvers.Channels do
  @moduledoc """
  Resolver module for channels
  """
  alias Re.Messages.Channels

  def all(params, %{context: %{current_user: current_user}}) do
    {:ok, Channels.all(current_user, params)}
  end
end
