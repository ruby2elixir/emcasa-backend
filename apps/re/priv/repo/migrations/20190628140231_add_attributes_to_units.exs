defmodule Re.Repo.Migrations.AddAttributesToUnits do
  use Ecto.Migration

  def change do
    alter table(:units) do
      add :matterport_code, :string
      add :is_exportable, :boolean
    end
  end
end
