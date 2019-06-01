defmodule ReIntegrations.Repo.Migrations.RenameBuildingsToBuildingPayloads do
  use Ecto.Migration

  def change do
    rename(table(:orulo_buildings), to: table(:orulo_building_payloads))
  end
end
