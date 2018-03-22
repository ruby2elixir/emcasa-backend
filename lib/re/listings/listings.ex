defmodule Re.Listings do
  @moduledoc """
  Context for listings.
  """
  @behaviour Bodyguard.Policy

  alias Re.{
    Listing,
    Listings.Filter,
    Listings.Queries,
    Repo
  }

  alias Ecto.Changeset

  defdelegate authorize(action, user, params), to: Re.Listings.Policy

  def paginated(params \\ %{}) do
    Queries.active()
    |> Queries.order_by()
    |> Queries.preload()
    |> Filter.apply(params)
    |> Repo.paginate(params)
  end

  def get(id), do: do_get(Listing, id)

  def get_preloaded(id), do: do_get(Queries.preload(), id)

  def insert(params, address, user) do
    %Listing{}
    |> Changeset.change(address_id: address.id)
    |> Changeset.change(user_id: user.id)
    |> Listing.changeset(params, user.role)
    |> Repo.insert()
  end

  def update(listing, params, address, user) do
    listing
    |> Changeset.change(address_id: address.id)
    |> Listing.changeset(params, user.role)
    |> Repo.update()
  end

  def delete(listing) do
    listing
    |> Changeset.change(is_active: false)
    |> Repo.update()
  end

  def activate(listing) do
    listing
    |> Changeset.change(is_active: true)
    |> Repo.update()
  end

  defp do_get(query, id) do
    case Repo.get(query, id) do
      nil -> {:error, :not_found}
      listing -> {:ok, listing}
    end
  end
end
