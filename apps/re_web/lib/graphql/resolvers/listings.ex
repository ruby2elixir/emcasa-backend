defmodule ReWeb.Resolvers.Listings do
  @moduledoc """
  Resolver module for listing queries and mutations
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias Re.{
    Addresses,
    Addresses.Neighborhoods,
    Filtering,
    Listings,
    Listings.Featured,
    Listings.History.Price,
    Listings.Related,
    PriceSuggestions
  }

  def index(params, %{context: %{current_user: current_user}}) do
    pagination = Map.get(params, :pagination, %{})
    filtering = Map.get(params, :filters, %{})

    params =
      params
      |> Map.merge(pagination)
      |> Map.merge(filtering)
      |> Map.merge(%{current_user: current_user})

    listing_index =
      params
      |> Listings.paginated()
      |> Map.put(:filters, filtering)

    {:ok, listing_index}
  end

  def show(%{id: id}, %{context: %{current_user: current_user}}) do
    with {:ok, listing} <- Listings.get(id),
         :ok <- Bodyguard.permit(Listings, :show_listing, current_user, listing) do
      {:ok, listing}
    end
  end

  def insert(%{input: listing_params}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :create_listing, current_user, listing_params),
         {:ok, address} <- get_address(listing_params),
         {:ok, listing} <- Listings.insert(listing_params, address, current_user) do
      {:ok, listing}
    else
      {:error, _, error, _} -> {:error, error}
      error -> error
    end
  end

  defp get_address(%{address: address_params}), do: Addresses.insert_or_update(address_params)
  defp get_address(%{address_id: id}), do: Addresses.get_by_id(id)
  defp get_address(_), do: {:error, :bad_request}

  def update(%{id: id, input: listing_params}, %{
        context: %{current_user: current_user}
      }) do
    with {:ok, listing} <- Listings.get(id),
         :ok <- Bodyguard.permit(Listings, :update_listing, current_user, listing),
         {:ok, address} <- get_address(listing_params),
         {:ok, listing} <- Listings.update(listing, listing_params, address, current_user) do
      {:ok, listing}
    end
  end

  def is_active(%{status: "active"}, _, _), do: {:ok, true}
  def is_active(_, _, _), do: {:ok, false}

  def score(%{score: score}, _, %{context: %{current_user: current_user}}) do
    case Bodyguard.permit(Listings, :show_score, current_user, %{}) do
      :ok -> {:ok, score}
      _ -> {:ok, nil}
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

  def favorites(user, params, %{context: %{loader: loader, current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :per_user, current_user, user) do
      loader
      |> Dataloader.load(Listings, {:favorited, params}, user)
      |> on_load(fn loader ->
        {:ok, Dataloader.get(loader, Listings, {:favorited, params}, user)}
      end)
    end
  end

  def owned(user, params, %{context: %{loader: loader, current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :per_user, current_user, user) do
      loader
      |> Dataloader.load(
        Listings,
        {:listings, Map.merge(params, %{has_admin_rights: true})},
        user
      )
      |> on_load(fn loader ->
        {:ok,
         Dataloader.get(
           loader,
           Listings,
           {:listings, Map.merge(params, %{has_admin_rights: true})},
           user
         )}
      end)
    end
  end

  def price_history(listing, _, %{context: %{loader: loader, current_user: current_user}}) do
    case Bodyguard.permit(Listings, :show_stats, current_user, listing) do
      :ok ->
        loader
        |> Dataloader.load(Price, :price_history, listing)
        |> on_load(fn loader ->
          {:ok, Dataloader.get(loader, Price, :price_history, listing)}
        end)

      _ ->
        {:ok, nil}
    end
  end

  def suggested_price(listing, _, %{context: %{current_user: current_user}}) do
    case Bodyguard.permit(Listings, :suggested_price, current_user, listing) do
      :ok -> do_suggest_price(listing)
      _ -> {:ok, nil}
    end
  end

  defp do_suggest_price(listing) do
    case PriceSuggestions.suggest_price(listing) do
      {:error, :street_not_covered} -> {:ok, nil}
      suggested_price -> suggested_price
    end
  end

  def price_recently_reduced(listing, _, %{context: %{loader: loader}}) do
    params = %{
      datetime: Timex.shift(Timex.now(), weeks: -2),
      current_price: listing.price
    }

    loader
    |> Dataloader.load(Price, {:price_history, params}, listing)
    |> on_load(&price_reduced?(&1, params, listing))
  end

  defp price_reduced?(loader, params, listing) do
    case Dataloader.get(loader, Price, {:price_history, params}, listing) do
      [] -> {:ok, false}
      prices when is_list(prices) -> {:ok, true}
      _ -> {:ok, false}
    end
  end

  def related(listing, params, %{context: %{current_user: current_user}}) do
    pagination = Map.get(params, :pagination, %{})
    filtering = Map.get(params, :filters, %{})

    params =
      params
      |> Map.merge(pagination)
      |> Map.merge(filtering)
      |> Map.merge(%{current_user: current_user})

    {:ok, Related.get(listing, params)}
  end

  def relaxed(params, %{context: %{current_user: current_user}}) do
    pagination = Map.get(params, :pagination, %{})

    relaxed_filters =
      params
      |> Map.get(:filters, %{})
      |> Filtering.relax()

    params =
      params
      |> Map.merge(pagination)
      |> Map.merge(relaxed_filters)
      |> Map.merge(%{current_user: current_user})

    listing_index =
      params
      |> Listings.paginated()
      |> Map.put(:filters, relaxed_filters)

    {:ok, listing_index}
  end

  def neighborhoods(_, _), do: {:ok, Neighborhoods.all()}

  def featured(_, _), do: {:ok, Featured.get_graphql()}

  def vivareal_highlight(listing, _, %{context: %{current_user: current_user}}) do
    case Bodyguard.permit(Listings, :show_highlights, current_user, %{}) do
      :ok -> {:ok, listing.vivareal_highlight}
      error -> error
    end
  end

  def listing_deactivated_config(args, %{context: %{current_user: current_user}}) do
    config_subscription(args, current_user, "listing_deactivated")
  end

  def listing_activated_config(args, %{context: %{current_user: current_user}}) do
    config_subscription(args, current_user, "listing_activated")
  end

  def listing_updated_config(args, %{context: %{current_user: current_user}}) do
    config_subscription(args, current_user, "listing_updated")
  end

  def listing_inserted_config(_args, %{context: %{current_user: current_user}}) do
    case current_user do
      %{role: "admin"}  -> {:ok, topic: "listing_inserted"}
      %{} -> {:error, :unauthorized}
      _ -> {:error, :unauthenticated}
    end
  end

  def listing_deactivate_trigger(%{id: id}), do: "listing_deactivated:#{id}"

  def listing_activate_trigger(%{id: id}), do: "listing_activated:#{id}"

  def update_listing_trigger(%{id: id}), do: "listing_updated:#{id}"

  def insert_listing_trigger(_arg), do: "listing_inserted"

  defp config_subscription(%{id: id}, %{role: "admin"}, topic),
    do: {:ok, topic: "#{topic}:#{id}"}

  defp config_subscription(_args, %{}, _topic), do: {:error, :unauthorized}
  defp config_subscription(_args, _, _topic), do: {:error, :unauthenticated}
end
