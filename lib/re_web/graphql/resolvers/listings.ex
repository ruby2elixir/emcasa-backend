defmodule ReWeb.Resolvers.Listings do
  @moduledoc """
  Resolver module for listing queries and mutations
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias Re.{
    Addresses,
    Listings,
    Listings.PriceHistories,
    PriceSuggestions
  }

  def index(params, _) do
    pagination = Map.get(params, :pagination, %{})
    filtering = Map.get(params, :filters, %{})

    {:ok, Listings.paginated(Map.merge(pagination, filtering))}
  end

  def show(%{id: id}, _), do: Listings.get(id)

  def insert(%{input: %{address: address_params} = listing_params}, %{
        context: %{current_user: current_user}
      }) do
    with :ok <- Bodyguard.permit(Listings, :create_listing, current_user, listing_params),
         {:ok, address, _changeset} <- Addresses.insert_or_update(address_params),
         {:ok, listing} <- Listings.insert(listing_params, address, current_user) do
      {:ok, listing}
    else
      {:error, _, error, _} -> {:error, error}
      error -> error
    end
  end

  def update(%{id: id, input: %{address: address_params} = listing_params}, %{
        context: %{current_user: current_user}
      }) do
    with {:ok, listing} <- Listings.get(id),
         :ok <- Bodyguard.permit(Listings, :update_listing, current_user, listing),
         {:ok, address, address_changeset} <- Addresses.insert_or_update(address_params),
         {:ok, listing, listing_changeset} <-
           Listings.update(listing, listing_params, address, current_user) do
      send_email_if_not_admin(listing, current_user, listing_changeset, address_changeset)

      {:ok, listing}
    end
  end

  def activate(%{id: id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :activate_listing, current_user, %{}),
         {:ok, listing} <- Listings.get_preloaded(id),
         do: Listings.activate(listing)
  end

  def deactivate(%{id: id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :deactivate_listing, current_user, %{}),
         {:ok, listing} <- Listings.get(id),
         do: Listings.deactivate(listing)
  end

  def per_user(_, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :per_user, current_user, %{}),
         do: {:ok, Listings.per_user(current_user)}
  end

  def price_history(listing, _, %{context: %{loader: loader, current_user: current_user}}) do
    case Bodyguard.permit(Listings, :show_stats, current_user, listing) do
      :ok ->
        loader
        |> Dataloader.load(Listings, :price_history, listing)
        |> on_load(fn loader ->
          {:ok, Dataloader.get(loader, Listings, :price_history, listing)}
        end)

      _ ->
        {:ok, nil}
    end
  end

  def suggested_price(listing, _, %{context: %{current_user: current_user}}) do
    case Bodyguard.permit(Listings, :suggested_price, current_user, listing) do
      :ok -> {:ok, PriceSuggestions.suggest_price(listing)}
      _ -> {:ok, nil}
    end
  end

  def price_recently_reduced(listing, _, %{context: %{loader: loader}}) do
    params = %{
      datetime: Timex.shift(Timex.now(), weeks: -2),
      current_price: listing.price
    }

    loader
    |> Dataloader.load(PriceHistories, {:price_history, params}, listing)
    |> on_load(&price_reduced?(&1, params, listing))
  end

  defp price_reduced?(loader, params, listing) do
    case Dataloader.get(loader, PriceHistories, {:price_history, params}, listing) do
      [] -> {:ok, false}
      prices when is_list(prices) -> {:ok, true}
      _ -> {:ok, false}
    end
  end

  @emails Application.get_env(:re, :emails, ReWeb.Notifications.Emails)
  @env Application.get_env(:re, :env)

  defp send_email_if_not_admin(
         listing,
         %{role: "user"} = user,
         listing_changeset,
         address_changeset
       ) do
    changes = Enum.concat(listing_changeset.changes, address_changeset.changes)
    @emails.listing_updated(user, listing, changes)
  end

  defp send_email_if_not_admin(
         %{is_active: true} = listing,
         %{role: "admin"},
         %{changes: %{price: new_price}},
         _
       ) do
    case @env do
      "staging" -> :nothing
      _ -> @emails.price_updated(new_price, listing)
    end
  end

  defp send_email_if_not_admin(_, %{role: "admin"}, _, _), do: :nothing
end
