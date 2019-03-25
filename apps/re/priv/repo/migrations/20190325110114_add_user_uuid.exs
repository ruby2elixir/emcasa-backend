defmodule Re.Repo.Migrations.AddUserUuid do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :uuid, :uuid
    end

    create unique_index(:users, [:uuid])
  end
end
