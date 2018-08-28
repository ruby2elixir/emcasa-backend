defmodule Re.Repo.Migrations.CreateDistrict do
  use Ecto.Migration

  def change do
    create table(:districts) do
      add :state, :string
      add :city, :string
      add :name, :string
      add :description, :text

      timestamps()
    end

    create unique_index(:districts, [:state, :city, :name], name: :neighborhood)
  end
end
