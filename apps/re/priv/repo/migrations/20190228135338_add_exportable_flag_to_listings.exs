defmodule Re.Repo.Migrations.AddExportableFlagToListings do
  use Ecto.Migration

  def up do
    alter table(:listings) do
      add :is_exportable, :boolean, default: true
    end
  end

  def down do
    alter table(:listings) do
      remove :is_exportable
    end
  end
end
