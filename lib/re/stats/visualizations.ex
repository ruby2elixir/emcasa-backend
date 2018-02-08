defmodule Re.Stats.Visualizations do
  @moduledoc """
  Module responsible for storing visualizations
  """
  use GenServer

  require Logger

  alias Re.{
    Listing,
    Stats.ListingVisualization,
    Repo,
    User
  }

  def listing(listing, user, conn \\ %{})

  def listing(%Listing{} = listing, %User{} = user, _conn) do
    GenServer.cast(__MODULE__, {:listing_user, listing.id, user.id})
  end

  def listing(%Listing{} = listing, nil, details) do
    GenServer.cast(__MODULE__, {:listing_anon, listing.id, details})
  end

  def listing(_, _, _), do: Logger.warn("Listing visualization did not match.")

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(args), do: {:ok, args}

  def handle_cast({:listing_user, listing_id, user_id}, state) do
    case insert(%{listing_id: listing_id, user_id: user_id}) do
      {:ok, _} ->
        {:noreply, state}

      {:error, reason} ->
        Logger.warn("Listing visualization was not inserted: #{inspect(reason)}")
        {:noreply, state}
    end
  end

  def handle_cast({:listing_anon, listing_id, details}, state) do
    case insert(%{listing_id: listing_id, details: details}) do
      {:ok, _} ->
        {:noreply, state}

      {:error, reason} ->
        Logger.warn("Listing visualization was not inserted: #{inspect(reason)}")
        {:noreply, state}
    end
  end

  defp insert(params) do
    %ListingVisualization{}
    |> ListingVisualization.changeset(params)
    |> Repo.insert()
  end
end
