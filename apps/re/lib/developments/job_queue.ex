defmodule Re.Developments.JobQueue do
  @moduledoc """
  Module for processing buyer leads to extract only necessary attributes
  Also attempts to associate user and listings
  """
  use EctoJob.JobQueue, table_name: "units_jobs"

  require Ecto.Query
  require Logger

  alias Re.{
    Addresses,
    Developments,
    Developments.Listings,
    Repo,
    Units
  }

  alias Ecto.Multi

  def perform(%Multi{} = multi, %{"type" => "new_unit", "uuid" => uuid}) do
    {:ok, %{development_uuid: development_uuid}} = {:ok, unit} = Units.get(uuid)
    {:ok, %{address_id: address_id}} = {:ok, development} = Developments.get(development_uuid)
    {:ok, _address} = Addresses.get_by_id(address_id)

    params =
      Listings.listing_from_unit(unit, development)
      |> Map.put(:development_uuid, development_uuid)
      |> Map.put(:address_id, address_id)

    Re.Listing.development_changeset(params, %{})
    |> insert(multi)
    |> Repo.transaction()

    # |> Listings.insert(development: development, address: address)
  end

  defp insert(changeset, multi) do
    Multi.insert(multi, :listing, changeset)
  end
end
