defmodule ReIntegrations.Orulo do
  @moduledoc """
  Context module to use importers.
  """
  alias ReIntegrations.{
    Orulo.BuildingPayload,
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
      %BuildingPayload{}
      |> BuildingPayload.changeset(params)

    uuid = Changeset.get_field(changeset, :uuid)

    multi
    |> Multi.insert(:building, changeset)
    |> JobQueue.enqueue(:building_parse, %{
      "type" => "parse_building_into_development",
      "uuid" => uuid
    })
    |> Repo.transaction()
  end

  def insert_development_from_building_payload(multi, building_uuid) do
    with building <- Repo.get(BuildingPayload, building_uuid),
         address_params <- Mapper.building_payload_into_address_params(building),
         development_params <- Mapper.building_payload_into_development_params(building),
         {:ok, transaction} <- insert_transaction(multi, address_params, development_params) do
      {:ok, transaction}
    else
      err -> err
    end
  end

  defp insert_transaction(multi, address_params, development_params) do
    multi
    |> Multi.run(:insert_address, fn _repo, _changes ->
      insert_address(address_params)
    end)
    |> Multi.run(:insert_development, fn _repo, %{insert_address: new_address} ->
      insert_development(development_params, new_address)
    end)
    |> Repo.transaction()
  end

  defp insert_address(params), do: Re.Addresses.insert_or_update(params)

  defp insert_development(params, address), do: Re.Developments.insert(params, address)
end
