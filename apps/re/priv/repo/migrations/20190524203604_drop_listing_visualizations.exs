defmodule Re.Repo.Migrations.DropListingVisualizations do
  use Ecto.Migration

  def up do
    drop table(:listing_visualizations)
    drop table(:tour_visualizations)
    drop table(:in_person_visits)
  end

  def down do
    create table(:listing_visualizations) do
      add :listing_id, references(:listings)
      add :user_id, references(:users)
      add :details, :text

      timestamps()
    end

    create index(:listing_visualizations, [:listing_id])
    create index(:listing_visualizations, [:user_id])

    create table(:tour_visualizations) do
      add :listing_id, references(:listings)
      add :user_id, references(:users)
      add :details, :text

      timestamps()
    end

    create index(:tour_visualizations, [:listing_id])
    create index(:tour_visualizations, [:user_id])

    create table(:in_person_visits) do
      add :listing_id, references(:listings)
      add :date, :utc_datetime

      timestamps()
    end

    create index(:in_person_visits, [:listing_id])
  end
end
