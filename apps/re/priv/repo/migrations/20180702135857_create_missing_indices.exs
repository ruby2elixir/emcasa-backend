defmodule Re.Repo.Migrations.CreateMissingIndices do
  use Ecto.Migration

  def change do
    create index(:listings, [:address_id])
    create index(:images, [:listing_id])
    create index(:price_histories, [:listing_id])
  end
end
