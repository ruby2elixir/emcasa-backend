defmodule ReWeb.Notifications.Emails.Server do
  @moduledoc """
  Module responsible for sending email
  """
  use GenServer

  require Logger

  alias ReWeb.Notifications.Emails.Mailer

  @spec start_link :: GenServer.start_link()
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init(term) :: {:ok, term}
  def init(args), do: {:ok, args}

  @spec handle_cast({atom(), atom(), [any]}, any) :: {:noreply, any}
  def handle_cast({module, function, args}, state) do
    case :erlang.apply(module, function, args) do
      %Swoosh.Email{} = email ->
        deliver(email, state)

      error ->
        Logger.error("Email creation failed. Reason: #{inspect(error)}")
        {:noreply, [{:error, error, {module, function, args}} | state]}
    end
  end

  defp deliver(email, state) do
    case Mailer.deliver(email) do
      {:ok, _} ->
        {:noreply, state}

      error ->
        Logger.error("Email delivery failed. Reason: #{inspect(error)}")
        {:noreply, [{:error, error, email} | state]}
    end
  end
end
