defmodule Re.ListingsV2 do
  @moduledoc """
  Context for listings.
  """
  alias Ecto.Changeset
  alias Re.{Listing, Repo}

  def insert(listing_params, address_id, user_id) do
    listing_params =
      listing_params
      |> Map.put("address_id", address_id)
      |> Map.put("user_id", user_id)

    %Listing{}
    |> Listing.insert_changeset(listing_params)
    |> Repo.insert()
  end

  def update(listing, listing_params, address_id) do
    listing
    |> Listing.update_changeset(listing_params)
    |> Changeset.change(address_id: address_id)
    |> Repo.update()
  end
end
