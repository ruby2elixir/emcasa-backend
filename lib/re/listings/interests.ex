defmodule Re.Listings.Interests do
  @moduledoc """
  Context to manage operation between users and listings
  """

  alias Re.{
    Listings.Interest,
    Repo
  }

  def show_interest(listing_id, params) do
    params = Map.put(params, "listing_id", listing_id)

    %Interest{}
    |> Interest.changeset(params)
    |> Repo.insert()
  end
end
