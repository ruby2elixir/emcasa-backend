defmodule ReIntegrations.Orulo do
  @moduledoc """
  Context module to use importers.
  """
  alias ReIntegrations.{
    Orulo.Building,
    Orulo.JobQueue,
    Orulo.Mapper,
    Repo
  }

  alias Ecto.{
    Changeset,
    Multi
  }

  def get_building_payload(id) do
    %{"type" => "import_development_from_orulo", "external_id" => id}
    |> JobQueue.new()
    |> Repo.insert()
  end

  def multi_building_insert(multi, params) do
    changeset =
      %Building{}
      |> Building.changeset(params)

    uuid = Changeset.get_field(changeset, :uuid)

    Multi.insert(multi, :building, changeset)
    |> JobQueue.enqueue(:building_parse, %{
      "type" => "parse_building_into_development",
      "uuid" => uuid
    })
    |> Repo.transaction()
  end

  def insert_development_from_building(uuid) do
    with building <- Repo.get(Building, uuid),
         address_params <- Mapper.building_payload_into_address_params(building),
         {:ok, new_address} <- Re.Addresses.insert_or_update(address_params),
         development_params <- Mapper.building_payload_into_development_params(building),
         {:ok, new_development} <- Re.Developments.insert(development_params, new_address) do
      {:ok, new_development}
    else
      err -> err
    end
  end
end
