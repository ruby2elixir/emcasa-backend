defmodule Re.Interests do
  @moduledoc """
  Context to manage operation between users and listings
  """

  alias Re.{
    Addresses,
    Interest,
    Interests.ContactRequest,
    Interests.NotifyWhenCovered,
    InterestType,
    PriceSuggestions,
    Repo,
    User
  }

  import Ecto.Query

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(_query, _args), do: Re.Interest

  def show_interest(params) do
    %Interest{}
    |> Interest.changeset(params)
    |> Repo.insert()
  end

  def show_interest(listing_id, params) do
    params = Map.put(params, "listing_id", listing_id)

    %Interest{}
    |> Interest.changeset(params)
    |> Repo.insert()
  end

  def preload(interest), do: Repo.preload(interest, :interest_type)

  def get_types do
    Repo.all(from(it in InterestType, where: it.enabled == true, order_by: {:asc, :id}))
  end

  def request_contact(params, user) do
    %ContactRequest{}
    |> ContactRequest.changeset(params)
    |> attach_user(user)
    |> Repo.insert()
  end

  def request_price_suggestion(params, user) do
    with {:ok, address} <- Addresses.insert_or_update(params.address),
         {:ok, request} <- PriceSuggestions.create_request(params, address, user),
         request <- Repo.preload(request, :address),
         suggested_price <- PriceSuggestions.suggest_price(request) do
      {:ok, request, suggested_price}
    end
  end

  def notify_when_covered(params, user \\ nil) do
    %NotifyWhenCovered{}
    |> NotifyWhenCovered.changeset(params)
    |> attach_user(user)
    |> Repo.insert()
  end

  defp attach_user(changeset, %User{id: id}),
    do: ContactRequest.changeset(changeset, %{user_id: id})

  defp attach_user(changeset, _), do: changeset
end
