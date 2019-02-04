defmodule Mix.Tasks.Re.Addresses.PadRightPostalCodeWithZeros do
  use Mix.Task
  import Mix.Ecto
  require Logger

  alias Re.{
    Address,
    Addresses,
    Listing,
    Listings.Queries,
    Repo
  }

  @shortdoc "Fix invalid postal codes"

  def run(_) do
    ensure_started(Re.Repo, [])

    find_partial_postal_code_addresses()
    |> Enum.map(&update_postal_code(&1))
  end

  defp find_partial_postal_code_addresses() do
    Queries.preload_relations(Listing, :address)
    |> Repo.all()
    |> Enum.filter(&partial_postal_code?(&1.address.postal_code))
  end

  @partial_postal_code_regex ~r/^[0-9]{5}$/

  defp partial_postal_code?(postal_code) do
    Regex.match?(@partial_postal_code_regex, postal_code)
  end

  defp update_postal_code(%{address: address} = listing) do
    params =
      Map.put(%{}, :street, address.street)
      |> Map.put(:postal_code, "#{address.postal_code}-000")
      |> Map.put(:street_number, address.street_number)

    Logger.info("Updating listing: #{listing.id}")

    case Addresses.get(params) do
      {:ok, correct_address} -> move_listings_to_correct_address(listing, correct_address)
      {:error, :not_found} -> update_pad_postal_code(address)
    end
  end

  defp move_listings_to_correct_address(listing, new_address) do
    changeset = Ecto.Changeset.change(listing, address_id: new_address.id)

    case Repo.update(changeset) do
      {:ok, listing} -> Logger.info("Sucessfully updated listing: #{listing.id}")
      {:error, changeset} -> Logger.info("Failed on update: #{changeset.errors}")
    end
  end

  defp update_pad_postal_code(address) do
    changeset =
      Ecto.Changeset.change(address)
      |> Address.pad_trailing_with_zeros()

    case Repo.update(changeset) do
      {:ok, listing} -> Logger.info("Sucessfully updated listing: #{listing.id}")
      {:error, changeset} -> Logger.info("Failed on update: #{changeset.errors}")
    end
  end
end
