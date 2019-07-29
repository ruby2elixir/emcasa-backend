defmodule Re.AlikeTeller.Server do
  @moduledoc """
  Module responsible for storing similar listing mapping
  """
  use GenServer

  alias Re.AlikeTeller

  @spec start_link :: GenServer.start_link()
  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @spec init(term) :: {:ok, term}
  def init(_), do: {:ok, [], {:continue, :load_aliketeller}}

  def handle_continue(:load_aliketeller, state) do
    AlikeTeller.load_aliketeller()

    {:noreply, state}
  end

  def handle_cast(:load_aliketeller, state) do
    AlikeTeller.load_aliketeller()

    {:noreply, state}
  end
end
