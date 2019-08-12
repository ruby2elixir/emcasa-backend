defmodule Re.Repo.Migrations.RemoveIsActiveFromListings do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      remove :is_active
    end
  end
end
