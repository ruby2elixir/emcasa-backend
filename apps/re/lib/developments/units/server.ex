defmodule Re.Developments.Units.Server do
  @moduledoc """
  Module responsible for replicate unit data on listings.
  """
  use GenServer

  require Logger

  alias Re.{
    Listings,
    Developments.Units.Propagator,
    PubSub,
    Units
  }

  @spec start_link :: GenServer.start_link()
  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @spec init(term) :: {:ok, term}
  def init(args) do
    PubSub.subscribe("new_unit")
    PubSub.subscribe("update_unit")

    {:ok, args}
  end

  @spec handle_info(map(), any) :: {:noreply, any}
  def handle_info(%{topic: "new_unit", type: :new, new: unit}, state) do
    with {:ok, listing} <- Listings.get(unit.listing_id),
         units <- Units.get_by_listing(unit.listing_id),
         {:ok, _listing} <- Propagator.update_listing(listing, units) do
      {:noreply, state}
    else
      error ->
        Logger.warn("Error when copy unit info to listing. Reason: #{inspect(error)}")

        {:noreply, [error | state]}
    end
  end

  @spec handle_info(map(), any) :: {:noreply, any}
  def handle_info(
        %{topic: "update_unit", type: :update, content: %{new: unit}},
        state
      ) do
    with {:ok, listing} <- Listings.get(unit.listing_id),
         units <- Units.get_by_listing(unit.listing_id),
         {:ok, _listing} <- Propagator.update_listing(listing, units) do
      {:noreply, state}
    else
      error ->
        Logger.warn("Error when copy unit info to listing. Reason: #{inspect(error)}")

        {:noreply, [error | state]}
    end
  end

  def handle_info(_, state), do: {:noreply, state}

  def handle_call(:inspect, _caller, state), do: {:reply, state, state}
end
