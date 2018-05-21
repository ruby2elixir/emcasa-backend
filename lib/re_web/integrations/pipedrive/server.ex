defmodule ReWeb.Integrations.Pipedrive.Server do
  @moduledoc """
  GenServer for handling pipedrive operations
  """
  use GenServer

  require Logger

  alias Re.{
    Repo,
    Stats.InPersonVisit
  }

  alias ReWeb.Integrations.Pipedrive.Client

  @attribute_key "226c74dbe45d5db69bbda19d6de53371db8a964a"

  @spec start_link :: GenServer.start_link()
  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @spec init(term) :: {:ok, term}
  def init(args), do: {:ok, args}

  @spec handle_cast({atom, map}, any) :: {:noreply, any}
  def handle_cast(
        {:handle_webhook, %{"deal_id" => deal_id, "marked_as_done_time" => done_time} = params},
        state
      ) do
    Logger.info("Webhook received with params #{inspect(params)}")

    deal_id
    |> get_listing_id()
    |> save_visit(done_time)

    {:noreply, state}
  end

  defp get_listing_id(deal_id) do
    deal_id
    |> fetch_deal()
    |> extract_listing_id()
  end

  defp fetch_deal(deal_id), do: Client.get("deals/#{deal_id}")

  defp extract_listing_id({:ok, %{body: body}}) do
    body
    |> Poison.decode!()
    |> Map.get("data")
    |> Map.get(@attribute_key)
  end

  defp save_visit(listing_id, done_time) when is_integer(listing_id) do
    %InPersonVisit{}
    |> InPersonVisit.changeset(%{listing_id: listing_id, date: done_time})
    |> Repo.insert()

    Logger.info("In Person Visit recorded for listing #{listing_id} at #{done_time}")
  end

  defp save_visit(_, _), do: Logger.info("Listing ID is empty")
end
