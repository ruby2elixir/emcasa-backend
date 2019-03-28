defmodule Re.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :name, :string, null: false
      add :name_slug, :string, null: false
      add :category, :string, null: false, default: "infrastructure"

      timestamps()
    end

    create unique_index(:tags, [:name_slug])
  end
end
