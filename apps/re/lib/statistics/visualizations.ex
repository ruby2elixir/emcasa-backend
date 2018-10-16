defmodule Re.Statistics.Visualizations do
  @moduledoc """
  Module responsible for storing visualizations
  """
  use GenServer

  require Logger

  alias Re.{
    Listing,
    Repo,
    User
  }

  alias Re.Statistics.{
    ListingVisualization,
    TourVisualization
  }

  @type action :: :listing_visualization | :tour_visualization

  @spec listing(Listing.t(), User.t() | nil, String.t()) :: GenServer.cast()
  def listing(listing, user, details \\ "")

  def listing(%Listing{}, %User{} = %{role: "admin"}, _), do: :ok

  def listing(%Listing{} = listing, %User{} = user, details) do
    GenServer.cast(__MODULE__, {:listing_visualization, listing.id, user.id, details})
  end

  def listing(%Listing{} = listing, nil, details) do
    GenServer.cast(__MODULE__, {:listing_visualization, listing.id, nil, details})
  end

  def listing(_, _, _), do: Logger.warn("Listing visualization did not match.")

  @spec tour(Listing.t(), User.t() | nil, String.t()) :: GenServer.cast()
  def tour(listing, user, details \\ "")

  def tour(%Listing{}, %User{} = %{role: "admin"}, _), do: :ok

  def tour(%Listing{} = listing, %User{} = user, details) do
    GenServer.cast(__MODULE__, {:tour_visualization, listing.id, user.id, details})
  end

  def tour(%Listing{} = listing, nil, details) do
    GenServer.cast(__MODULE__, {:tour_visualization, listing.id, nil, details})
  end

  def tour(_, _, _), do: Logger.warn("Tour visualization did not match.")

  @spec start_link :: GenServer.start_link()
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init(term) :: {:ok, term}
  def init(args), do: {:ok, args}

  @spec handle_cast({action, integer(), integer() | nil, map()}, any) :: {:noreply, any}
  def handle_cast({:listing_visualization, listing_id, user_id, details}, state) do
    case insert_listing(%{listing_id: listing_id, user_id: user_id, details: details}) do
      {:ok, _} ->
        {:noreply, state}

      {:error, reason} ->
        Logger.warn("Listing visualization was not inserted: #{inspect(reason)}")
        {:noreply, state}
    end
  end

  def handle_cast({:tour_visualization, listing_id, user_id, details}, state) do
    case insert_tour(%{listing_id: listing_id, user_id: user_id, details: details}) do
      {:ok, _} ->
        {:noreply, state}

      {:error, reason} ->
        Logger.warn("Tour visualization was not inserted: #{inspect(reason)}")
        {:noreply, state}
    end
  end

  defp insert_listing(params) do
    %ListingVisualization{}
    |> ListingVisualization.changeset(params)
    |> Repo.insert()
  end

  defp insert_tour(params) do
    %TourVisualization{}
    |> TourVisualization.changeset(params)
    |> Repo.insert()
  end
end
