defmodule Re.Repo.Migrations.AddSuggestedPriceListing do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :suggested_price, :float
    end
  end
end
