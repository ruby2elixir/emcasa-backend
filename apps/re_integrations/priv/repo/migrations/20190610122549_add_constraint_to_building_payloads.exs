defmodule ReIntegrations.Repo.Migrations.AddConstraintToBuildingPayloads do
  use Ecto.Migration

  def change do
    create unique_index(:orulo_building_payloads, [:external_id])
  end
end
