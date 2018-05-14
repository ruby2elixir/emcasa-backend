defmodule ReWeb.Integrations.Pipedrive do

  require Logger

  @activity_params ["deal_id", "marked_as_done_time"]

  def handle_webhook(%{"event" => "updated.activity", "current" => %{"type" => "visita_ao_imvel"} = current, "previus" => previous}) do
    if current["done"] && !previous["done"] do
      GenServer.cast(__MODULE__.Server, {:handle_webhook, Map.take(current, @activity_params)})
    end
  end

  def handle_webhook(_), do: Logger.info("Unhandled webhook")
end
