defmodule Re.Repo.Migrations.UpdateListingsTable do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :price, :integer
      add :area, :integer
    end
  end
end
