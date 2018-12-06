defmodule Re.History.Server do
  @moduledoc """
  Module responsible for storing attributes history
  """
  use GenServer

  require Logger

  alias Re.{
    Listings.PriceHistories,
    PubSub
  }

  @spec start_link :: GenServer.start_link()
  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @spec init(term) :: {:ok, term}
  def init(args) do
    PubSub.subscribe("update_listing")

    {:ok, args}
  end

  @spec handle_info(map(), any) :: {:noreply, any}
  def handle_info(
        %{
          topic: "update_listing",
          type: :update,
          content: %{new: listing, changeset: %{changes: %{price: _}, data: %{price: price}}}
        },
        state
      ) do
    case PriceHistories.insert(listing, price) do
      {:ok, _listing} ->
        {:noreply, state}

      error ->
        Logger.warn("Error when saving price history. Reason: #{inspect(error)}")

        {:noreply, [error | state]}
    end
  end

  def handle_info(_, state), do: {:noreply, state}

  def handle_call(:inspect, _caller, state), do: {:reply, state, state}
end
