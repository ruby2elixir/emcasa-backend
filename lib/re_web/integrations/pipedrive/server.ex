defmodule ReWeb.Integrations.Pipedrive.Server do
  @moduledoc """
  GenServer for handling pipedrive operations
  """
  use GenServer

  require Logger

  @spec start_link :: GenServer.start_link()
  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @spec init(term) :: {:ok, term}
  def init(args), do: {:ok, args}

  @spec handle_cast({atom, map}, any) :: {:noreply, any}
  def handle_cast({:handle_webhook, params}, state) do
    {:noreply, state}
  end

end
