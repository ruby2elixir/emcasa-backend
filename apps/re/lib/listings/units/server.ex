# maybe move this module to units
defmodule Re.Listings.Units.Server do
  @moduledoc """
  Module responsible for replicate unit data on listings.
  """
  use GenServer

  require Logger

  alias Re.{
    Listings.Units.Propagator,
    PubSub
  }

  @spec start_link :: GenServer.start_link()
  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @spec init(term) :: {:ok, term}
  def init(args) do
    PubSub.subscribe("new_unit")

    {:ok, args}
  end

  @spec handle_info(map(), any) :: {:noreply, any}
  def handle_info(
        %{
          topic: "new_unit",
          type: :new,
          content: %{new: unit}
        },
        state
      ) do
    case Propagator.update_listing(unit.listing, unit) do
      {:ok, _listing} ->
        {:noreply, state}

      error ->
        Logger.warn("Error when copy unit info to listing. Reason: #{inspect(error)}")

        {:noreply, [error | state]}
    end
  end

  def handle_info(_, state), do: {:noreply, state}
end
