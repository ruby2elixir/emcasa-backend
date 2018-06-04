defmodule Re.Repo.Migrations.CreateChannel do
  use Ecto.Migration

  def up do
    create table(:channels) do
      add :listing_id, references(:listings)
      add :participant1_id, references(:users)
      add :participant2_id, references(:users)

      timestamps()
    end

    create index(:channels, [:listing_id])
    create index(:channels, [:participant1_id])
    create index(:channels, [:participant2_id])

    create unique_index(:channels, [:participant1_id, :participant2_id, :listing_id], name: :topic)

    flush()

    alter table(:messages) do
      add :channel_id, references(:channels)
    end

    create index(:messages, [:channel_id])
  end

  def down do
    alter table(:messages) do
      remove :channel_id
    end

    flush()

    drop table(:channels)
  end
end
