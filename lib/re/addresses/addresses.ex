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
    address = Repo.get(Address, listing.address_id) |> Repo.preload(:listings)
    address_changeset = Ecto.Changeset.change(address, address_params)
      case map_size(address_changeset.changes) do
        0 ->
          listing.address_id

        _ ->
          changeset = Address.changeset(%Address{}, address_params)
          case Repo.insert(changeset) do
            {:ok, address} -> address.id
            {:error, changeset} -> {:error, changeset}
          end
      end
  end

end
