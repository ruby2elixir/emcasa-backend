defmodule Re.Addresses do

  alias Re.{
    Address,
    Repo
  }

  import Ecto.Query

  def get_ids_with_neighborhood(neighborhood) do
    Repo.all(from a in Address,
             select: a.id,
             where: a.neighborhood == ^neighborhood)
  end

  def find_or_create(address_params) do
    case find_unique(address_params) do
      nil -> insert(address_params)
      address -> {:ok, address}
    end
  end

  defp find_unique(address_params) do
    Repo.get_by(Address,
      street: address_params["street"] || "",
      postal_code: address_params["postal_code"] || "",
      street_number: address_params["street_number"] || "")
  end

  def update(listing, address_params) do
    if changed?(listing, address_params) do
      find_or_create(address_params)
    else
      {:ok, listing.address}
    end
  end

  defp changed?(listing, address_params) do
    %{changes: changes} = Address
    |> Repo.get(listing.address_id)
    |> Repo.preload(:listings)
    |> Address.changeset(address_params)

    changes != %{}
  end

  defp insert(address_params) do
    %Address{}
    |> Address.changeset(address_params)
    |> Repo.insert()
  end

end
