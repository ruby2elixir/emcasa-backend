defmodule Re.Repo.Migrations.AddListingsFavorites do
  use Ecto.Migration

  def change do
    create table(:listings_favorites) do
      add :listing_id, references(:listings)
      add :user_id, references(:users)

      timestamps()
    end

    create index(:listings_favorites, [:listing_id])
    create index(:listings_favorites, [:user_id])
  end
end
