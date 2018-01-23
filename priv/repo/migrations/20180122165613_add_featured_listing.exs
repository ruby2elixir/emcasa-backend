defmodule Re.Repo.Migrations.AddFeaturedListing do
  use Ecto.Migration

  def change do
    create table(:featured_listings) do
      add(:position, :integer)
      add(:listing_id, references(:listings))

      timestamps()
    end

    create(index(:featured_listings, [:listing_id]))
  end
end
