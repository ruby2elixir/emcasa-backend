defmodule Re.Repo.Migrations.ChangeUnitsToUseUuidAsPrimaryKey do
  use Ecto.Migration

  def change do
    alter table(:units) do
      remove(:id)

      modify(:uuid, :uuid, primary_key: true)
    end
  end
end
