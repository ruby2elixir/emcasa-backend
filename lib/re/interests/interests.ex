defmodule Re.Interests do
  @moduledoc """
  Context to manage operation between users and listings
  """

  alias Re.{
    Interest,
    InterestType,
    Repo
  }

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(query, _args), do: query

  def show_interest(listing_id, params) do
    params = Map.put(params, "listing_id", listing_id)

    %Interest{}
    |> Interest.changeset(params)
    |> Repo.insert()
  end

  def preload(interest), do: Repo.preload(interest, :interest_type)

  def get_types do
    Repo.all(InterestType)
  end
end
