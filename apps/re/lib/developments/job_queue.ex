defmodule Re.Developments.JobQueue do
  @moduledoc """
  Module for processing jobs related with developments domain.
  """
  use EctoJob.JobQueue, table_name: "units_jobs"

  require Ecto.Query
  require Logger

  alias Re.{
    Developments.Listings,
    Developments.Orulo.Building,
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

  def perform(%Multi{} = multi, %{"type" => "import_development_from_orulo", "external_id" => id}) do
    case ReIntegrations.Importers.Importer.get_building_from_orulo(id) do
      {:ok, payload} ->
        Building.changeset(%Building{}, %{external_id: id, payload: payload})
        |> Repo.insert()

      {:error, error} ->
        Logger.error(error)
    end
  end
end
