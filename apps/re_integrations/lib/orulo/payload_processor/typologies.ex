defmodule ReIntegrations.Orulo.PayloadProcessor.Typologies do
  @moduledoc """
  Module to process typologies payloads into units.
  """
  alias Ecto.Multi

  alias Re.Developments

  alias ReIntegrations.{
    Orulo.TypologyPayload,
    Orulo.TypologyMapper,
    Repo
  }

  def process_typologies(multi, topology_uuid) do
    typology_payload = Repo.get(TypologyPayload, topology_uuid)
    {:ok, development} = Developments.get_by_orulo_id(typology_payload.building_id)

    %{payload: %{"typologies" => payload}} = typology_payload

    multi
    |> insert_units(payload, development)
    |> Repo.transaction()
  end

  @static_params %{
    status: "inactive"
  }

  defp insert_units(multi, typologies, development) do
    Multi.run(multi, :insert_units, fn _repo, _changes ->
      insertion_results =
        Enum.map(typologies, fn typology ->
          params =
            typology
            |> TypologyMapper.typology_payload_into_unit_params()

          params
          |> Map.merge(@static_params)
          |> Re.Units.insert(development)
        end)

      {:ok, insertion_results}
    end)
  end
end
