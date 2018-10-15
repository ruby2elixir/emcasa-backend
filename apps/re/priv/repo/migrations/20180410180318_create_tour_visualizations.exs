defmodule Re.Repo.Migrations.CreateTourVisualizations do
  use Ecto.Migration

  def change do
    create table(:tour_visualizations) do
      add(:listing_id, references(:listings))
      add(:user_id, references(:users))
      add(:details, :text)

      timestamps()
    end

    create(index(:tour_visualizations, [:listing_id]))
    create(index(:tour_visualizations, [:user_id]))
  end
end
