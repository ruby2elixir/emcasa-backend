defmodule Mix.Tasks.Re.FixInvalidPostalCodes do
  use Mix.Task
  import Mix.Ecto

  alias Re.{
    Address,
    Listings.Queries,
    Repo
  }

  @shortdoc "Fix invalid postal codes"

  def run(_) do
    ensure_started(Re.Repo, [])

    find_partial_postal_code_addresses()
    |> Enum.map(&update_postal_code(&1))

    IO.puts("All postal codes updated!")
  end

  defp find_partial_postal_code_addresses() do
    Queries.active()
    |> Queries.preload_relations(:address)
    |> Repo.all()
    |> Enum.filter(&partial_postal_code?(&1.address.postal_code))
    |> Enum.map(& &1.address)
  end

  @partial_postal_code_regex ~r/^[0-9]{5}$/

  defp partial_postal_code?(postal_code) do
    Regex.match?(@partial_postal_code_regex, postal_code)
  end

  defp update_postal_code(address) do
    IO.inspect("Updating address #{address.id} ...")

    changeset =
      Ecto.Changeset.change(address)
      |> Address.pad_trailing_with_zeros()

    case Repo.update(changeset) do
      {:ok, _} ->
        IO.inspect("Address #{address.id} updated with success!")

      {:error, changeset} ->
        IO.inspect("Error #{changeset.errors} on Address #{address.id} updating!")
    end
  end
end
