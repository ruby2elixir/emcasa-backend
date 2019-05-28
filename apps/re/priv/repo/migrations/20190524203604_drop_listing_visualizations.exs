defmodule Re.Repo.Migrations.DropListingVisualizations do
  use Ecto.Migration

  def change do
    drop table(:listing_visualizations)
    drop table(:tour_visualizations)
    drop table(:in_person_visits)
  end
end
