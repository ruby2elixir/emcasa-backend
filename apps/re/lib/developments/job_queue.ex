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
    Units
  }

  alias Ecto.Multi

  def perform(%Multi{} = multi, %{"type" => "new_unit", "uuid" => uuid}) do
    {:ok, %{development_uuid: development_uuid}} = {:ok, unit} = Units.get(uuid)
    {:ok, %{address_id: address_id}} = {:ok, development} = Developments.get(development_uuid)
    {:ok, address} = Addresses.get_by_id(address_id)

    params = Listings.listing_params_from_unit(unit, development)

    Listings.multi_insert(multi, params, development: development, address: address)
  end
end
