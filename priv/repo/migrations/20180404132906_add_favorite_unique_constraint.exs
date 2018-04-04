defmodule Re.Repo.Migrations.AddFavoriteUniqueConstraint do
  use Ecto.Migration

  def up do
    create unique_index(:listings_favorites, [:listing_id, :user_id], name: :unique_favorite)
  end

  def down do
    drop index(:listings_favorites, [:listing_id, :user_id], name: :unique_favorite)
  end
end
