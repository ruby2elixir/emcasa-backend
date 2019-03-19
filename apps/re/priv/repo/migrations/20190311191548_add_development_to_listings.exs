defmodule Re.Repo.Migrations.AddDevelopmentToListings do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :development_id, references(:developments)
    end
  end
end
