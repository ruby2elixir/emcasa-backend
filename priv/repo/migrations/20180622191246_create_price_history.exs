defmodule Re.Repo.Migrations.CreatePriceHistory do
  use Ecto.Migration

  def change do
    create table(:price_histories) do
      add :price, :integer
      add :listing_id, references(:listings)

      timestamps()
    end
  end
end
