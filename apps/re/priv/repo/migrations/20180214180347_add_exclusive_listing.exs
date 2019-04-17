defmodule Re.Repo.Migrations.AddExclusiveListing do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :is_exclusive, :boolean
    end
  end
end
