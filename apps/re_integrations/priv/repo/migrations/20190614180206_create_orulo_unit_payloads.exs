defmodule ReIntegrations.Repo.Migrations.CreateOruloUnitPayloads do
  use Ecto.Migration

  def change do
    create table(:orulo_unit_payloads, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :building_id, :string
      add :typology_id, :string
      add :payload, :map, null: false, default: %{}
      timestamps()
    end
  end
end
