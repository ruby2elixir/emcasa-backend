defmodule Re.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :message, :text
      add :notified, :boolean
      add :read, :boolean

      add :sender_id, references(:users)
      add :receiver_id, references(:users)
      add :listing_id, references(:listings)

      timestamps()
    end

    create index(:messages, [:sender_id])
    create index(:messages, [:receiver_id])
    create index(:messages, [:listing_id])
  end
end
