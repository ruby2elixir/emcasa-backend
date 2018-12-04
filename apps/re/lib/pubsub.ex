defmodule Re.PubSub do
  @moduledoc """
  PubSub helper functions
  """

  def subscribe(topic), do: Phoenix.PubSub.subscribe(__MODULE__, topic)

  def publish_new(new, topic) do
    case new do
      {:ok, new} ->
        Phoenix.PubSub.broadcast(__MODULE__, topic, %{topic: topic, type: :new, new: new})

        {:ok, new}

      error ->
        error
    end
  end

  def publish_update(new, old, topic) do
    case new do
      {:ok, new} ->
        Phoenix.PubSub.broadcast(__MODULE__, topic, %{new: new, type: :update, old: old})

        {:ok, new}

      error ->
        error
    end
  end
end
