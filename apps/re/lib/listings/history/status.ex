defmodule Re.Listings.History.Status do
  @moduledoc """
  Context for handling listing's status history
  """
  import Ecto.Query

  alias Re.{
    Listings.StatusHistory,
    Repo
  }

  def insert(listing, status) do
    %StatusHistory{}
    |> StatusHistory.changeset(%{status: status, listing_id: listing.id})
    |> Repo.insert()
  end
end
