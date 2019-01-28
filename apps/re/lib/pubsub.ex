defmodule Re.PubSub do
  @moduledoc """
  PubSub helper functions
  """

  def subscribe(topic), do: Phoenix.PubSub.subscribe(__MODULE__, topic)

  def publish_new(new, topic, metadata \\ %{}) do
    case new do
      {:ok, new} ->
        Phoenix.PubSub.broadcast(__MODULE__, topic, %{
          topic: topic,
          type: :new,
          new: new,
          metadata: metadata
        })

        {:ok, new}

      error ->
        error
    end
  end

  def publish_update(content, changeset, topic, metadata \\ %{}) do
    case content do
      {:ok, content} ->
        Phoenix.PubSub.broadcast(__MODULE__, topic, %{
          topic: topic,
          type: :update,
          content: %{new: content, changeset: changeset},
          metadata: metadata
        })

        {:ok, content}

      error ->
        error
    end
  end
end
