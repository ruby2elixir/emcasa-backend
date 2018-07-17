defmodule ReWeb.Resolvers.Channels do
  @moduledoc """
  Resolver module for channels
  """
  alias Re.{
    Messages,
    Messages.Channels
  }

  def all(params, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Messages, :index, current_user, params) do
      channels =
        params
        |> Map.put(:current_user_id, current_user.id)
        |> Channels.all()

      {:ok, channels}
    end
  end
end
