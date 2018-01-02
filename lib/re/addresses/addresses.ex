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
    address_changeset = Address.changeset(%Address{}, address_params)
    case Repo.get_by(Address,
                  street: address_params["street"] || "",
                  postal_code: address_params["postal_code"] || "",
                  street_number: address_params["street_number"] || "") do

        nil ->
          case Repo.insert(address_changeset) do
            {:ok, address} -> address.id

            {:error, changeset} -> {:error, changeset}
          end

        address -> address.id
      end
  end

  def update(listing, address_params) do
    Address
    |> Repo.get(listing.address_id)
    |> Repo.preload(:listings)
    |> Address.changeset(address_params)
    |> case do
      %{changes: %{}} -> listing.address_id
      changeset -> Repo.insert(changeset, on_conflict: :nothing)
    end
  end

end
