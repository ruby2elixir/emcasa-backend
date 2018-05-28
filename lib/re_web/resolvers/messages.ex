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
    with :ok <- Bodyguard.permit(Messages, :index, current_user, %{}) do
      {:ok, %{user: current_user, messages: Messages.get(current_user, params)}}
    end
  end
end
