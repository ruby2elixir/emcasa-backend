defmodule Re.Favorites do
  @moduledoc """
  Context for favorites.
  """

  @behaviour Bodyguard.Policy

  alias Re.{
    Favorite,
    Repo
  }

  defdelegate authorize(action, user, params), to: Re.Favorites.Policy

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(_query, _args), do: Re.Favorite

  def add(listing, user) do
    %Favorite{}
    |> Favorite.changeset(%{listing_id: listing.id, user_id: user.id})
    |> Repo.insert(on_conflict: :nothing)
  end

  def remove(listing, user) do
    case Repo.get_by(Favorite, listing_id: listing.id, user_id: user.id) do
      nil -> {:error, :not_found}
      favorite -> Repo.delete(favorite)
    end
  end

  def users(listing) do
    listing
    |> Repo.preload(:favorited)
    |> Map.get(:favorited)
  end
end
