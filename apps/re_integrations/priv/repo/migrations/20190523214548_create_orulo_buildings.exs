defmodule ReIntegrations.Repo.Migrations.CreateOruloBuildings do
  use Ecto.Migration

  def change do
    create table(:re_integrations_orulo_buildings, primary_key: false) do
      add(:uuid, :uuid, primary_key: true)
      add(:external_id, :integer)
      add(:payload, :map, null: false, default: %{})
      timestamps()
    end
  end
end
