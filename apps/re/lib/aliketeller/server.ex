defmodule Re.AlikeTeller.Server do
  @moduledoc """
  Module responsible for storing similar listing mapping
  """
  use GenServer
  require Logger
  require Mockery.Macro

  @url Application.get_env(:re, :aliketeller_url, "")

  @spec start_link :: GenServer.start_link()
  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @spec init(term) :: {:ok, term}
  def init(_), do: {:ok, [], {:continue, :load_aliketeller}}

  def handle_continue(:load_aliketeller, state), do: load_aliketeller(state)

  def handle_cast(:load_aliketeller, state), do: load_aliketeller(state)

  def handle_call(:inspect, _caller, state), do: {:reply, state, state}

  defp load_aliketeller(state) do
    create_ets_table()

    with {:ok, %{status_code: 200, body: body}} <- get_payload(),
         {:ok, payload} <- Jason.decode(body) do
      save_on_ets(payload)
    else
      error -> Logger.warn("Error loading aliketeller payload: #{inspect(error)}")
    end

    {:noreply, state}
  end

  defp get_payload do
    @url
    |> URI.parse()
    |> http_client().get()
  end

  defp save_on_ets(%{"data" => data}), do: Enum.each(data, &do_save_on_ets/1)

  defp do_save_on_ets(%{"listing_uuid" => uuid, "suggested_listing_uuids" => uuids}) do
    :ets.insert(:aliketeller, {uuid, uuids})
  end

  defp create_ets_table do
    case :ets.whereis(:aliketeller) do
      :undefined ->
        :ets.new(:aliketeller, [:set, :protected, :named_table, read_concurrency: true])

      _ ->
        :ok
    end
  end

  defp http_client, do: Mockery.Macro.mockable(HTTPoison)
end
