defmodule ReWeb.Resolvers.Messages do
  @moduledoc """
  Resolver module for messages
  """
  alias Re.Messages

  def send(params, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Messages, :send_message, current_user, %{}) do
      Messages.send(current_user, params)
    end
  end

  def get(params, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Messages, :index, current_user, %{}),
         messages <- Messages.get(current_user, params),
         [user] <- find_participant(messages, current_user) do
      {:ok, %{user: user, messages: messages}}
    end
  end

  defp find_participant(messages, %{id: current_user_id}) do
    participant_users =
      Enum.map(messages, &Map.get(&1, :sender)) ++ Enum.map(messages, &Map.get(&1, :receiver))

    participant_users
    |> Enum.uniq()
    |> Enum.reject(fn %{id: id} -> id == current_user_id end)
  end
end
