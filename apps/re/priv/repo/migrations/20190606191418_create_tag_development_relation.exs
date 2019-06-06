defmodule Re.Repo.Migrations.CreateTagDevelopmentRelation do
  use Ecto.Migration

  def change do
    create table(:developments_tags, primary_key: false) do
      add :development_uuid, references(:developments, column: :uuid, type: :uuid),
        primary_key: true

      add :tag_uuid, references(:tags, column: :uuid, type: :uuid), primary_key: true
    end

    create index(:developments_tags, [:development_uuid, :tag_uuid])
  end
end
