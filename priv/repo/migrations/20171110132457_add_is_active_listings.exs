defmodule Re.Repo.Migrations.AddIsActiveListings do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :is_active, :boolean, default: true
    end
  end
end
