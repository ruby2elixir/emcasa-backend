defmodule Re.History.Server do
  @moduledoc """
  Module responsible for storing attributes history
  """
  use GenServer

  require Logger

  alias Re.{
    Listings.PriceHistory,
    PubSub,
    Repo
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
        %{topic: "update_listing", type: :update, content: %{new: new, changeset: changeset}},
        state
      ) do
    case changeset do
      %{data: %{price: old_price}} ->
        %PriceHistory{}
        |> PriceHistory.changeset(%{price: old_price, listing_id: new.id})
        |> Repo.insert()

        {:noreply, state}

      _ ->
        {:noreply, state}
    end
  end

  def handle_info(_, state), do: {:noreply, state}

  def handle_call(:inspect, _caller, state), do: {:reply, state, state}
end
