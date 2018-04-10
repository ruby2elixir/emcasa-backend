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

  @type action :: :listing_visualization

  @spec listing(Listing.t(), User.t() | nil, map()) :: GenServer.cast()
  def listing(listing, user, details \\ %{})

  def listing(%Listing{} = listing, %User{} = user, details) do
    GenServer.cast(__MODULE__, {:listing_visualization, listing.id, user.id, details})
  end

  def listing(%Listing{} = listing, nil, details) do
    GenServer.cast(__MODULE__, {:listing_visualization, listing.id, nil, details})
  end

  def listing(_, _, _), do: Logger.warn("Listing visualization did not match.")

  @spec start_link :: GenServer.start_link()
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init(term) :: {:ok, term}
  def init(args), do: {:ok, args}

  @spec handle_cast({action, integer(), integer() | nil, map()}, any) :: {:noreply, any}
  def handle_cast({:listing_visualization, listing_id, user_id, details}, state) do
    case insert(%{listing_id: listing_id, user_id: user_id, details: details}) do
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
