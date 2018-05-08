defmodule ReWeb.Notifications.Emails.Server do
  @moduledoc """
  Module responsible for sending email
  """
  use GenServer

  require Logger

  alias Re.Accounts.Users

  alias ReWeb.{
    Schema,
    Notifications.Emails.Mailer,
    Notifications.UserEmail
  }

  alias ReWeb.Endpoint, as: PubSub

  @spec start_link :: GenServer.start_link()
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init(term) :: {:ok, term}
  def init(args) do
    case Absinthe.run(
           "subscription { emailChanged { id } }",
           Schema,
           context: %{pubsub: PubSub, current_user: :system}
         ) do
      {:ok, %{"subscribed" => topic}} -> PubSub.subscribe(topic)
      _ -> :nothing
    end

    {:ok, args}
  end

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

  @spec handle_info(Phoenix.Socket.Broadcast.t(), any) :: {:noreply, any}
  def handle_info(%Phoenix.Socket.Broadcast{payload: %{result: %{data: data}}}, state) do
    handle_data(data, state)
  end

  def handle_info(_, state), do: {:noreply, state}

  defp handle_data(%{"emailChanged" => %{"id" => user_id}}, state) do
    case Users.get(user_id) do
      {:ok, user} -> handle_cast({UserEmail, :change_email, [user]}, state)
      _ -> {:noreply, state}
    end
  end
end
