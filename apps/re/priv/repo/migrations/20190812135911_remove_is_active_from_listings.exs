defmodule Re.Repo.Migrations.RemoveIsActiveFromListings do
  use Ecto.Migration

  def up do
    alter table(:listings) do
      remove :is_active
    end
  end

  def down do
    alter table(:listings) do
      add :is_active, :boolean
    end
  end
end
