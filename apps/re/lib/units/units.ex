defmodule Re.Units do
  @moduledoc """
  Context module for unit. A unit represents realty/real estate properties,
  for a listing. A listing can have one or more units.
  """
  @behaviour Bodyguard.Policy

  alias Ecto.Changeset

  alias Re.{
    Listings,
    PubSub,
    Repo,
    Unit
  }

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(_query, _args), do: Re.Unit

  def insert(params, development, listing) do
    %Unit{}
    |> Changeset.change(development_uuid: development.uuid)
    |> Changeset.change(listing_id: listing.id)
    |> Unit.changeset(params)
    |> Repo.insert()
    |> publish_new()
  end

  def update_listing_price(
        %{price: unit_price} = new_unit,
        %{price: listing_price} = listing
      )
      when is_nil(listing_price) or unit_price < listing_price do
    Listings.update_price(listing, unit_price)
  end

  def update_listing_price(unit, _listing), do: unit

  defp publish_new(result), do: PubSub.publish_new(result, "new_unit")
end
