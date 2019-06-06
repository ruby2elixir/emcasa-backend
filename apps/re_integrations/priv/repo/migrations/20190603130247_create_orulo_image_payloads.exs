defmodule ReIntegrations.Repo.Migrations.CreateOruloImagePayloads do
  use Ecto.Migration

  def change do
    create table(:orulo_image_payloads, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :external_id, :integer
      add :payload, :map, null: false, default: %{}
      timestamps()
    end
  end
end
