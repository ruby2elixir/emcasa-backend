defmodule Re.Stats.Visualizations do
  @moduledoc """
  Module responsible for storing visualizations
  """
  use GenServer

  alias Re.{
    Listing,
    Stats.ListingVisualization,
    Repo,
    User
  }

  def listing(%Listing{} = listing, %User{} = user, _conn \\ %{}) do
    GenServer.cast(__MODULE__, {:listing_user, listing.id, user.id})
  end

  def listing(%Listing{} = listing, nil, details) do
    GenServer.cast(__MODULE__, {:listing_anon, listing.id, details})
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_cast({:listing_user, listing_id, user_id}, state) do
    insert(%{listing_id: listing_id, user_id: user_id})
    {:noreply, state}
  end

  def handle_cast({:listing_anon, listing_id, details}, state) do
    insert(%{listing_id: listing_id, details: details})
    {:noreply, state}
  end

  defp insert(params) do
    %ListingVisualization{}
    |> ListingVisualization.changeset(params)
    |> Repo.insert()
  end
end
