defmodule Re.Repo.Migrations.ChangeDevelopmentToUseUuidAsPrimaryKey do
  use Ecto.Migration

  def up do
    alter table(:developments) do
      add(:uuid, :uuid)
    end

    alter table(:images) do
      remove :development_id
    end

    alter table(:listings) do
      remove :development_id
    end

    flush()

    alter table(:developments) do
      remove(:id)

      modify(:uuid, :uuid, primary_key: true)
    end

    alter table(:images) do
      add :development_uuid, references(:developments, column: :uuid, type: :uuid)
    end

    alter table(:listings) do
      add :development_uuid, references(:developments, column: :uuid, type: :uuid)
    end
  end

  def down do
    alter table(:developments) do
      add(:id, :serial)
    end

    alter table(:images) do
      remove :development_id
    end

    alter table(:listings) do
      remove :development_id
    end

    flush()

    alter table(:developments) do
      remove(:uuid)
      modify(:id, :serial, primary_key: true)
    end

    alter table(:images) do
      add :development_id, references(:developments)
    end

    alter table(:listings) do
      add :development_id, references(:developments)
    end
  end
end
