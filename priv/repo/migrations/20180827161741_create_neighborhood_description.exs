defmodule Re.Repo.Migrations.CreateNeighborhoodDescription do
  use Ecto.Migration

  def change do
    create table(:neighborhood_descriptions) do
      add :state, :string
      add :city, :string
      add :neighborhood, :string
      add :description, :text

      timestamps()
    end

    create unique_index(:neighborhood_descriptions, [:state, :city, :neighborhood], name: :neighborhood)
  end
end
