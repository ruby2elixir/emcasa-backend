defmodule Re.Repo.Migrations.CreateInterestsUuid do
  use Ecto.Migration

  def change do
    alter table(:interests) do
      add :uuid, :uuid
    end

    create unique_index(:interests, [:uuid])
  end
end
