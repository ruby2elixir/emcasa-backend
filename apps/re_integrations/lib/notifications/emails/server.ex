defmodule ReIntegrations.Notifications.Emails.Server do
  @moduledoc """
  Module responsible for sending email
  """
  use GenServer
  use Retry

  require Logger

  alias Re.{
    PubSub,
    Repo
  }

  alias ReIntegrations.Notifications.Emails

  @env Application.get_env(:re, :env)

  @spec start_link :: GenServer.start_link()
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init(term) :: {:ok, term}
  def init(args) do
    if Mix.env() != :test do
      PubSub.subscribe("new_listing")
      PubSub.subscribe("contact_request")
      PubSub.subscribe("new_price_suggestion_request")
      PubSub.subscribe("notify_when_covered")
      PubSub.subscribe("tour_appointment")
      PubSub.subscribe("new_interest")
      PubSub.subscribe("update_listing")
    end

    {:ok, args}
  end

  def handle_call(:inspect, _caller, state), do: {:reply, state, state}

  @spec handle_cast({atom(), atom(), [any]}, any) :: {:noreply, any}

  def handle_cast({module, :price_updated, new_price, listing}, state) do
    replies =
      listing
      |> Repo.preload(:favorited)
      |> Map.get(:favorited)
      |> Enum.filter(&notify?/1)
      |> Enum.map(&handle_cast({module, :price_updated, [&1, new_price, listing]}, state))

    {:noreply, Enum.reduce(replies, state, fn {:noreply, st}, state -> [st | state] end)}
  end

  def handle_cast({module, :listing_added, user, listing}, state) do
    if notify?(user) do
      handle_cast({module, :listing_added, [user, listing]}, state)
    else
      {:noreply, state}
    end
  end

  def handle_cast({module, function, args}, state) do
    case :erlang.apply(module, function, args) do
      %Swoosh.Email{} = email ->
        deliver(email, state)

      error ->
        Logger.error("Email creation failed. Reason: #{inspect(error)}")
        {:noreply, [{:error, error, {module, function, args}} | state]}
    end
  end

  defp notify?(%{notification_preferences: %{email: false}}), do: false
  defp notify?(_), do: @env not in ~w(staging test)

  defp deliver(email, state) do
    retry with: exp_backoff() |> randomize() |> expiry(30_000), rescue_only: [TimeoutError] do
      Emails.Mailer.deliver(email)
    after
      {:ok, _} -> {:noreply, state}
    else
      error ->
        Logger.error("Email delivery failed. Reason: #{inspect(error)}")
        {:noreply, [{:error, error, email} | state]}
    end
  end

  @spec handle_info(map(), any) :: {:noreply, any}
  def handle_info(%{topic: "notify_when_covered", type: :new, new: notify_when_covered}, state) do
    handle_cast({Emails.User, :notification_coverage_asked, [notify_when_covered]}, state)
  end

  def handle_info(%{topic: "contact_request", type: :new, new: contact_request}, state) do
    case contact_request do
      %{user: nil} = contact_request ->
        handle_cast({Emails.User, :contact_request, [contact_request]}, state)

      %{user: user} = contact_request ->
        contact_request = Repo.preload(contact_request, :user)
        handle_cast({Emails.User, :contact_request, [merge_params(user, contact_request)]}, state)

      error ->
        {:noreply, [{:error, error} | state]}
    end
  end

  def handle_info(%{topic: "new_interest", type: :new, new: interest}, state) do
    interest = Repo.preload(interest, :interest_type)

    handle_cast({Emails.User, :notify_interest, [interest]}, state)
  end

  def handle_info(%{topic: "tour_appointment", type: :new, new: tour_appointment}, state) do
    tour_appointment = Repo.preload(tour_appointment, [:user, :listing])

    handle_cast({Emails.User, :tour_appointment, [tour_appointment]}, state)
  end

  def handle_info(%{topic: "new_listing", type: :new, new: listing}, state) do
    listing = Repo.preload(listing, :user)

    handle_cast({Emails.User, :listing_added_admin, [listing.user, listing]}, state)
  end

  def handle_info(
        %{topic: "update_listing", type: :update, content: %{new: listing, changes: changes}},
        state
      ) do
    listing = Repo.preload(listing, :user)

    handle_cast({Emails.User, :listing_updated, [listing.user, listing, changes]}, state)
  end

  def handle_info(
        %{
          topic: "new_price_suggestion_request",
          type: :new,
          new: %{req: request, price: {_, price}}
        },
        state
      ) do
    request = Repo.preload(request, [:address, :user])

    handle_cast({Emails.User, :price_suggestion_requested, [request, price]}, state)
  end

  def handle_info(_, state), do: {:noreply, state}

  defp merge_params(user, contact_request) do
    user = Map.take(user, ~w(name email phone)a)
    contact_request = Map.take(contact_request, ~w(name email phone message)a)
    Map.merge(user, contact_request, &map_merger/3)
  end

  defp map_merger(_key, nil, v2), do: v2
  defp map_merger(_key, v1, nil), do: v1
  defp map_merger(_key, _v1, v2), do: v2
end
