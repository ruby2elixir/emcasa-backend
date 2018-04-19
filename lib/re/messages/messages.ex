defmodule Re.Messages do
  @moduledoc """
  Context module for messages
  """
  @behaviour Bodyguard.Policy

  alias Re.{
    Message,
    Repo
  }

  defdelegate authorize(action, user, params), to: Re.Messages.Policy

  def send(sender, params) do
    params = Map.merge(params, %{sender_id: sender.id})

    %Message{}
    |> Message.changeset(params)
    |> Repo.insert()
  end
end
