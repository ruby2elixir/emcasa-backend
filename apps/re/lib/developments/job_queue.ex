defmodule Re.Developments.JobQueue do
  @moduledoc """
  Module for processing jobs related with developments domain.
  """
  use EctoJob.JobQueue, table_name: "units_jobs"

  require Ecto.Query
  require Logger

  alias Re.{
    Developments.Listings,
    Developments.Mirror,
    Repo,
    Unit
  }

  alias Ecto.Multi

  def perform(%Multi{} = multi, %{"type" => "mirror_new_unit_to_listing", "uuid" => uuid}) do
    %{development: %{address: address} = development} =
      unit =
      Unit
      |> Ecto.Query.preload(development: [:address])
      |> Repo.get(uuid)

    params = Listings.listing_params_from_unit(unit, development)

    Listings.multi_insert(multi, params, development: development, address: address, unit: unit)
  end

  def perform(%Multi{} = multi, %{"type" => "mirror_update_unit_to_listing", "uuid" => uuid}) do
    multi
    |> Multi.run(:mirror_unit, fn _repo, _changes ->
      Mirror.mirror_unit_update_to_listing(uuid)
    end)
    |> Repo.transaction()
  end
end
