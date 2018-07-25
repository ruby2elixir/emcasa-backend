defmodule Re.Repo.Migrations.AddBlacklists do
  use Ecto.Migration

  def change do
    create table(:listings_blacklists) do
      add :listing_id, references(:listings)
      add :user_id, references(:users)

      timestamps()
    end

    create index(:listings_blacklists, [:listing_id])
    create index(:listings_blacklists, [:user_id])
    create unique_index(:listings_blacklists, [:listing_id, :user_id], name: :unique_blacklist)
  end
end
