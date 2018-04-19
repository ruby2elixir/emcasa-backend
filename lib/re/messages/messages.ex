defmodule Re.Messages do
  @moduledoc """
  Context module for messages
  """
  alias Re.{
    Message,
    Repo
  }

  def send(sender, params) do
    params = Map.merge(params, %{sender_id: sender.id})

    %Message{}
    |> Message.changeset(params)
    |> Repo.insert()
  end

end
