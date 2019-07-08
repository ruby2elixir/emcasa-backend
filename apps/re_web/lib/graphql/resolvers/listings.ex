defmodule ReWeb.Resolvers.Listings do
  @moduledoc """
  Resolver module for listing queries and mutations
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias Re.{
    Addresses,
    Developments,
    Listings.Filters,
    Listings,
    Listings.Featured,
    Listings.History.Prices,
    Listings.Related,
    OwnerContacts,
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

  def per_development(development, params, %{
        context: %{loader: loader, current_user: current_user}
      }) do
    params =
      Map.put(
        params,
        :has_admin_rights,
        Bodyguard.permit?(Developments, :has_admin_rights, current_user, development)
      )

    loader
    |> Dataloader.load(Re.Listings, {:listings, params}, development)
    |> on_load(fn loader ->
      listings =
        loader
        |> Dataloader.get(
          Re.Listings,
          {:listings, params},
          development
        )

      {:ok, listings}
    end)
  end

  def show(%{id: id}, %{context: %{current_user: current_user}}) do
    with {:ok, listing} <- Listings.get(id),
         :ok <- Bodyguard.permit(Listings, :show_listing, current_user, listing) do
      {:ok, listing}
    end
  end

  def insert(%{input: %{development_uuid: _} = listing_params}, %{
        context: %{current_user: current_user}
      }) do
    with :ok <-
           Bodyguard.permit(Listings, :create_development_listing, current_user, listing_params),
         {:ok, address} <- get_address(listing_params),
         {:ok, development} <- get_development(listing_params),
         {:ok, listing} <-
           Developments.Listings.insert(listing_params,
             address: address,
             development: development
           ),
         {:ok, listing} <- Listings.upsert_tags(listing, Map.get(listing_params, :tags)) do
      {:ok, listing}
    else
      {:error, _, error, _} -> {:error, error}
      error -> error
    end
  end

  def insert(%{input: listing_params}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :create_listing, current_user, listing_params),
         {:ok, address} <- get_address(listing_params),
         {:ok, owner_contact} <- upsert_owner_contact(listing_params),
         {:ok, listing} <-
           Listings.insert(listing_params,
             address: address,
             user: current_user,
             owner_contact: owner_contact
           ),
         {:ok, listing} <- Listings.upsert_tags(listing, Map.get(listing_params, :tags)) do
      {:ok, listing}
    else
      {:error, _, error, _} -> {:error, error}
      error -> error
    end
  end

  defp get_address(%{address: address_params}), do: Addresses.insert_or_update(address_params)
  defp get_address(%{address_id: id}), do: Addresses.get_by_id(id)
  defp get_address(_), do: {:error, :bad_request}

  defp get_development(%{development_uuid: uuid}), do: Developments.get(uuid)
  defp get_development(_), do: {:error, :bad_request}

  def update(%{id: id, input: %{development_uuid: _} = listing_params}, %{
        context: %{current_user: current_user}
      }) do
    with {:ok, listing} <- Listings.get_partial_preloaded(id, [:address, :development]),
         :ok <- Bodyguard.permit(Listings, :update_development_listing, current_user, listing),
         address <- listing.address,
         development <- listing.development,
         {:ok, listing} <-
           Developments.Listings.update(listing, listing_params,
             address: address,
             development: development
           ),
         {:ok, listing} <- Listings.upsert_tags(listing, Map.get(listing_params, :tags)) do
      {:ok, listing}
    end
  end

  def update(%{id: id, input: listing_params}, %{
        context: %{current_user: current_user}
      }) do
    with {:ok, listing} <- Listings.get(id),
         :ok <- Bodyguard.permit(Listings, :update_listing, current_user, listing),
         {:ok, address} <- get_address(listing_params),
         {:ok, owner_contact} <- upsert_owner_contact(listing_params),
         {:ok, listing} <-
           Listings.update(listing, listing_params,
             address: address,
             user: current_user,
             owner_contact: owner_contact
           ),
         {:ok, listing} <- Listings.upsert_tags(listing, Map.get(listing_params, :tags)) do
      {:ok, listing}
    end
  end

  defp upsert_owner_contact(%{owner_contact: owner_contact}),
    do: OwnerContacts.upsert(owner_contact)

  defp upsert_owner_contact(_), do: {:ok, nil}

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

  def deactivate(%{id: id} = params, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :deactivate_listing, current_user, %{}),
         {:ok, listing} <- Listings.get(id),
         opts <- params |> Map.get(:input, %{}) |> Map.to_list(),
         do: Listings.deactivate(listing, opts)
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
        |> Dataloader.load(Prices, :price_history, listing)
        |> on_load(fn loader ->
          {:ok, Dataloader.get(loader, Prices, :price_history, listing)}
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

  defp do_suggest_price(%{suggested_price: nil} = listing) do
    case PriceSuggestions.suggest_price(listing) do
      {:ok, suggested_price} -> {:ok, suggested_price}
      _error -> {:ok, nil}
    end
  end

  defp do_suggest_price(%{suggested_price: suggested_price}), do: {:ok, suggested_price}

  def price_recently_reduced(listing, _, %{context: %{loader: loader}}) do
    params = %{
      datetime: Timex.shift(Timex.now(), weeks: -2),
      current_price: listing.price
    }

    loader
    |> Dataloader.load(Prices, {:price_history, params}, listing)
    |> on_load(&price_reduced?(&1, params, listing))
  end

  defp price_reduced?(loader, params, listing) do
    case Dataloader.get(loader, Prices, {:price_history, params}, listing) do
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
      |> Filters.relax()

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

  def featured(_, _), do: {:ok, Featured.get_graphql()}

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
      %{role: "admin"} -> {:ok, topic: "listing_inserted"}
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

  def get_uuid(listing, _, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Listings, :show_uuid, current_user, %{}) do
      {:ok, listing.uuid}
    end
  end
end
