defmodule Re.Developments.JobQueue do
  @moduledoc """
  Module for processing jobs related with developments domain.
  """
  use EctoJob.JobQueue, table_name: "units_jobs"

  alias Re.{
    Developments.Mirror,
    Repo
  }

  alias Ecto.Multi

  def perform(%Multi{} = multi, %{"type" => "mirror_new_unit_to_listing", "uuid" => uuid}) do
    multi
    |> Multi.run(:mirror_unit, fn _repo, _changes ->
      Mirror.mirror_unit_insert_to_listing(uuid)
    end)
    |> Repo.transaction()
  end

  def perform(%Multi{} = multi, %{"type" => "mirror_update_unit_to_listing", "uuid" => uuid}) do
    multi
    |> Multi.run(:mirror_unit, fn _repo, _changes ->
      Mirror.mirror_unit_update_to_listing(uuid)
    end)
    |> Repo.transaction()
  end

  def perform(%Multi{} = multi, %{
        "type" => "mirror_update_development_to_listings",
        "uuid" => uuid
      }) do
    multi
    |> Multi.run(:mirror_unit, fn _repo, _changes ->
      Mirror.mirror_development_update_to_listings(uuid)
    end)
    |> Repo.transaction()
  end
end
