defmodule Re.Repo.Migrations.RemoveFeaturedListings do
  use Ecto.Migration

  def change do
    drop table(:featured_listings)
  end
end
