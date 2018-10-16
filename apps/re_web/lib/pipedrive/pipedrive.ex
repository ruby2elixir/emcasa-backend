defmodule ReWeb.Pipedrive do
  @moduledoc """
  Module for handling pipedrive webhook structure
  """
  require Logger

  @activity_params ["deal_id", "marked_as_done_time"]
  @server Application.get_env(:re, :pipedrive, __MODULE__.Server)

  def validate_payload(%{
        "event" => "updated.activity",
        "current" => %{"type" => "visita_ao_imvel", "done" => true},
        "previous" => %{"done" => false}
      }),
      do: :ok

  def validate_payload(_) do
    Logger.info("Unhandled webhook")

    {:error, :not_handled}
  end

  def handle_webhook(%{"current" => current}),
    do: GenServer.cast(@server, {:handle_webhook, Map.take(current, @activity_params)})
end
