defmodule Re.Repo.Migrations.AddDevelopmentToUnits do
  use Ecto.Migration

  def change do
    alter table(:units) do
      add :development_uuid, references(:developments, column: :uuid, type: :uuid)
    end
  end
end
