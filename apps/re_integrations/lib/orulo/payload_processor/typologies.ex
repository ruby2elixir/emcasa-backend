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
    Orulo.TypologyMapper,
    Orulo.TypologyPayload,
    Orulo.UnitPayload,
    Repo
  }

  require Logger

  def process_typologies(multi, unit_payload_uuid) do
    %{
      building_id: building_id,
      typology_id: typology_id,
      payload: units_payload
    } = Repo.get(UnitPayload, unit_payload_uuid)

    %{payload: typology_payload} = Repo.get_by(TypologyPayload, building_id: building_id)
    typology_info = extract_typology_info_from_payload(typology_id, typology_payload)
    {:ok, development} = Developments.get_by_orulo_id(building_id)

    %{"units" => units} = units_payload

    multi
    |> insert_units_from_typologies(typology_info, development, units)
    |> Repo.transaction()
  end

  defp insert_units_from_typologies(multi, typology, development, units) do
    Multi.run(multi, :insert_units, fn _repo, _changes ->
      {successful_insertions, failed_insertions} =
        units
        |> Enum.map(&insert_unit(&1, typology, development))
        |> Keyword.split([:ok])

      log_failed_insertions(failed_insertions)

      {:ok, successful_insertions}
    end)
  end

  @static_params %{
    status: "active"
  }

  defp insert_unit(unit, typology, development) do
    typology
    |> TypologyMapper.typology_payload_into_unit_params(unit)
    |> Map.merge(@static_params)
    |> Units.insert(development)
  end

  defp extract_typology_info_from_payload(id, %{"typologies" => typologies}) do
    typologies
    |> Enum.filter(fn typology ->
      Map.get(typology, "id") == id
    end)
    |> List.first()
  end

  defp log_failed_insertions([]), do: nil

  defp log_failed_insertions(errors) do
    errors
    |> Enum.map(fn {:error, changeset} -> changeset end)
    |> Enum.map(&Logger.error("Failed to insert Orulo unit, reason: #{Kernel.inspect(&1)}"))
  end
end
