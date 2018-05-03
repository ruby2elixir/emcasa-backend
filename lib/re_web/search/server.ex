defmodule ReWeb.Search.Server do
  @moduledoc """
  GenServer for handling elasticsearch operations
  """
  use GenServer

  require Logger

  alias ReWeb.{
    Search.Cluster,
    Search.Store
  }

  @index "listings"

  @settings %{
    settings: "priv/elasticsearch/listings.json",
    store: Store,
    sources: [Re.Listing]
  }

  @type action :: :build_index | :cleanup_index | :put_document | :delete_document

  @spec start_link :: GenServer.start_link()
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init(term) :: {:ok, term}
  def init(args), do: {:ok, args}

  @spec handle_cast(action | {action, Listing.t()}, any) :: {:noreply, any}
  def handle_cast(:build_index, state) do
    case Elasticsearch.Index.hot_swap(Cluster, @index, @settings) do
      :ok -> Logger.debug("Listings index created.")
      error -> Logger.error("Listings index creation failed. Reason: #{inspect(error)}")
    end

    {:noreply, state}
  end

  def handle_cast(:cleanup_index, state) do
    case Elasticsearch.Index.clean_starting_with(Cluster, @index, 0) do
      :ok -> Logger.debug("Listings index cleaned.")
      error -> Logger.error("Listings index cleanup failed. Reason: #{inspect(error)}")
    end

    {:noreply, state}
  end

  def handle_cast({:put_document, listing}, state) do
    case Elasticsearch.put_document(Cluster, listing, @index) do
      {:ok, _doc} ->
        Logger.debug("Listing #{listing.id} added to index")

      error ->
        Logger.error(
          "Adding listing #{listing.id} to the index failed. Reason: #{inspect(error)}"
        )
    end

    {:noreply, state}
  end

  def handle_cast({:delete_document, listing}, state) do
    case Elasticsearch.delete_document(Cluster, listing, @index) do
      {:ok, _doc} ->
        Logger.debug("Listing #{listing.id} removed from index")

      error ->
        Logger.error(
          "Removing listing #{listing.id} from the index failed. Reason: #{inspect(error)}"
        )
    end

    {:noreply, state}
  end
end
