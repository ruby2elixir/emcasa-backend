defmodule Re.Developments.JobQueue do
  @moduledoc """
  Module for processing developments listings to extract attributes from unit and
  create an listing from
  """
  use EctoJob.JobQueue, table_name: "units_jobs"

  require Ecto.Query
  require Logger

  alias Re.{
    Addresses,
    Developments,
    Developments.Listings,
    Units
  }

  alias Ecto.Multi

  def perform(%Multi{} = multi, %{"type" => "new_unit", "uuid" => uuid}) do
    {:ok, %{development_uuid: development_uuid}} = {:ok, unit} = Units.get(uuid)
    {:ok, %{address_id: address_id}} = {:ok, development} = Developments.get(development_uuid)
    {:ok, address} = Addresses.get_by_id(address_id)

    params = Listings.listing_params_from_unit(unit, development)

    multi =
      {:ok, %{listing: listing}} =
      Listings.multi_insert(multi, params, development: development, address: address)

    Units.update(unit, %{}, development, listing)

    multi
  end
end
