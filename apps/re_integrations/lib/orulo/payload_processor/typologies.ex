defmodule ReIntegrations.Orulo.PayloadProcessor.Typologies do
  @moduledoc """
  Module to process typologies payloads into units.
  """
  alias Ecto.Multi

  alias Re.{
    Developments,
    Units
  }

  alias ReIntegrations.{
    Orulo.TypologyPayload,
    Orulo.TypologyMapper,
    Repo
  }

  def process_typologies(multi, typology_uuid) do
    typology_payload = Repo.get(TypologyPayload, typology_uuid)
    {:ok, development} = Developments.get_by_orulo_id(typology_payload.building_id)

    %{payload: %{"typologies" => typologies}} = typology_payload

    multi
    |> insert_units_from_typologies(typologies, development)
    |> Repo.transaction()
  end

  defp insert_units_from_typologies(multi, typologies, development) do
    Multi.run(multi, :insert_units, fn _repo, _changes ->
      insertion_results = Enum.map(typologies, &insert_unit(&1, development))
      {:ok, insertion_results}
    end)
  end

  @static_params %{
    status: "inactive",
    garage_type: "unknown"
  }

  defp insert_unit(typology, development) do
    typology
    |> TypologyMapper.typology_payload_into_unit_params()
    |> Map.merge(@static_params)
    |> Units.insert(development)
  end
end
