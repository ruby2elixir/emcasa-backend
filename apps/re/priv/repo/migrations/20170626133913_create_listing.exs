defmodule Re.Repo.Migrations.CreateListing do
  use Ecto.Migration

  def change do
    create table(:listings) do
      add :description, :string
      add :name, :string

      timestamps()
    end

  end
end
