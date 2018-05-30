defmodule Re.Messages.Channels do
  @moduledoc """
  Context module for channels
  """

  alias Re.{
    Channel,
    Repo
  }

  def get(id) when is_integer(id), do: Repo.get(Channel, id)
  def get(params) when is_map(params), do: Repo.get_by(Channel, params)

  def find_or_create_channel(message_params) do
    params = translate_params(message_params)

    case get(params) do
      nil -> %Channel{}
        |> Channel.changeset(params)
        |> Repo.insert()
      channel -> {:ok, channel}
    end
  end

  def translate_params(message_params) do
    {receiver_id, ""} = Integer.parse(message_params.receiver_id)
    [part1, part2] = Enum.sort([message_params.sender_id, receiver_id])

    %{
      participant1_id: part1,
      participant2_id: part2,
      listing_id: message_params.listing_id
    }
  end
end
