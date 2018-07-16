defmodule ReWeb.Resolvers.Channels do
  @moduledoc """
  Resolver module for channels
  """
  alias Re.Messages.Channels

  def all(params, %{context: %{current_user: current_user}}) do
    channels =
      params
      |> Map.put(:current_user_id, current_user.id)
      |> Channels.all()

    {:ok, channels}
  end
end
