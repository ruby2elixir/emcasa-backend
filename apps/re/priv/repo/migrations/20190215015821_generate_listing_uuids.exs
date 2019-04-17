defmodule Re.Repo.Migrations.GenerateListingUuids do
  use Ecto.Migration

  require Ecto.Query

  def up do
    alter table(:listings) do
      add :uuid, :string
    end

    create(unique_index(:listings, [:uuid]))
  end

  def down do
    alter table(:listings) do
      remove :uuid
    end
  end
end
