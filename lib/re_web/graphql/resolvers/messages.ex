defmodule ReWeb.Resolvers.Messages do
  @moduledoc """
  Resolver module for messages
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias Re.Messages

  def send(params, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Messages, :send_message, current_user, %{}) do
      Messages.send(current_user, params)
    end
  end

  def get(params, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Messages, :index, current_user, %{}),
         messages <- Messages.get_by_user(current_user, params),
         user <- find_participant(messages, current_user) do
      {:ok, %{user: user, messages: messages}}
    end
  end

  def mark_as_read(%{id: id}, %{context: %{current_user: current_user}}) do
    with {:ok, message} <- Messages.get(id),
         :ok <- Bodyguard.permit(Messages, :mark_as_read, current_user, message),
         do: Messages.mark_as_read(message)
  end

  defp find_participant(messages, %{id: current_user_id}) do
    participant_users =
      Enum.map(messages, &Map.get(&1, :sender)) ++ Enum.map(messages, &Map.get(&1, :receiver))

    participant_users
    |> Enum.uniq()
    |> Enum.reject(fn %{id: id} -> id == current_user_id end)
    |> case do
      [user] -> user
      _ -> nil
    end
  end

  def count_unread(channel, _, %{context: %{loader: loader, current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Messages, :index, current_user, channel) do
      loader
      |> Dataloader.load(Messages, {:messages, %{read: false}}, channel)
      |> on_load(&do_count_unread(&1, channel))
    end
  end

  defp do_count_unread(loader, channel) do
    {:ok, Enum.count(Dataloader.get(loader, Messages, {:messages, %{read: false}}, channel))}
  end
end
