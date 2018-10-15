defmodule Re.Repo.Migrations.ListingVisualizations do
  use Ecto.Migration

  def change do
    create table(:listing_visualizations) do
      add(:listing_id, references(:listings))
      add(:user_id, references(:users))
      add(:details, :text)

      timestamps()
    end

    create(index(:listing_visualizations, [:listing_id]))
    create(index(:listing_visualizations, [:user_id]))
  end
end
