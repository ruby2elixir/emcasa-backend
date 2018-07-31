defmodule Re.Blacklists do
  @moduledoc """
  Context for blacklists.
  """

  @behaviour Bodyguard.Policy

  alias Re.{
    Blacklist,
    Repo
  }

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(_query, _args), do: Re.Blacklist

  def add(listing, user) do
    %Blacklist{}
    |> Blacklist.changeset(%{listing_id: listing.id, user_id: user.id})
    |> Repo.insert(on_conflict: :nothing)
  end

  def remove(listing, user) do
    case Repo.get_by(Blacklist, listing_id: listing.id, user_id: user.id) do
      nil -> {:error, :not_found}
      blacklist -> Repo.delete(blacklist)
    end
  end

  def users(listing) do
    listing
    |> Repo.preload(:blacklisted)
    |> Map.get(:blacklisted)
  end
end
