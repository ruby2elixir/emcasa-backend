defmodule Re.Repo.Migrations.AddTimestampsToUnits do
  use Ecto.Migration

  def change do
    alter table(:units) do
      timestamps()
    end
  end
end
