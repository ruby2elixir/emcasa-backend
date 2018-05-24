defmodule ReWeb.Search.Server do
  @moduledoc """
  GenServer for handling elasticsearch operations
  """
  use GenServer

  require Logger

  alias Re.Listings

  alias ReWeb.{
    Schema,
    Search.Cluster,
    Search.Store
  }

  alias ReWeb.Endpoint, as: PubSub

  @index "listings"

  @settings %{
    settings: "priv/elasticsearch/listings.json",
    store: Store,
    sources: [Re.Listing]
  }

  @type action :: :build_index | :cleanup_index

  @spec start_link :: GenServer.start_link()
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init(term) :: {:ok, term}
  def init(args) do
    if Mix.env() != :test do
      case Absinthe.run(
             "subscription { listingActivated { id } }",
             Schema,
             context: %{pubsub: PubSub, current_user: :system}
           ) do
        {:ok, %{"subscribed" => topic}} -> PubSub.subscribe(topic)
        _ -> :nothing
      end

      case Absinthe.run(
             "subscription { listingDeactivated { id } }",
             Schema,
             context: %{pubsub: PubSub, current_user: :system}
           ) do
        {:ok, %{"subscribed" => topic}} -> PubSub.subscribe(topic)
        _ -> :nothing
      end
    end

    {:ok, args}
  end

  @spec handle_cast(action, any) :: {:noreply, any}
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

  def handle_info(%Phoenix.Socket.Broadcast{payload: %{result: %{data: data}}}, state) do
    handle_data(data)

    {:noreply, state}
  end

  defp handle_data(%{"listingActivated" => %{"id" => listing_id}}) do
    {:ok, listing} = Listings.get_preloaded(listing_id)

    case Elasticsearch.put_document(Cluster, listing, @index) do
      {:ok, _doc} ->
        Logger.debug(fn -> "Listing #{listing.id} added to index" end)

      error ->
        Logger.error(
          "Adding listing #{listing.id} to the index failed. Reason: #{inspect(error)}"
        )
    end
  end

  defp handle_data(%{"listingDeactivated" => %{"id" => listing_id}}) do
    {:ok, listing} = Listings.get_preloaded(listing_id)

    case Elasticsearch.delete_document(Cluster, listing, @index) do
      {:ok, _doc} ->
        Logger.debug(fn -> "Listing #{listing.id} removed from index" end)

      error ->
        Logger.error(
          "Removing listing #{listing.id} from the index failed. Reason: #{inspect(error)}"
        )
    end
  end
end
