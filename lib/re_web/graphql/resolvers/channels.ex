defmodule ReWeb.Resolvers.Channels do
  @moduledoc """
  Resolver module for channels
  """
  alias Re.Messages.Channels

  def all(_, %{context: %{current_user: current_user}}) do
    channels =
      current_user
      |> Channels.all()
      |> Enum.map(&Channels.count_unread/1)
      |> Enum.map(&Channels.set_last_message/1)

    {:ok, channels}
  end
end
