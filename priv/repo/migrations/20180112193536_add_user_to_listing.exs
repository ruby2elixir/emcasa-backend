defmodule Re.Repo.Migrations.AddUserToListing do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :user_id, references(:users)
    end

    create index(:listings, [:user_id])
  end
end
