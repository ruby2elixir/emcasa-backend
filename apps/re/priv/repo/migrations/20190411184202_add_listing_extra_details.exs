defmodule Re.Repo.Migrations.AddListingExtraDetails do
  use Ecto.Migration

  def up do
    alter table(:listings) do
      add :orientation, :string
      add :floor_count, :integer
      add :unit_per_floor, :integer
      add :sun_period, :string
      add :elevators, :integer
      add :construction_year, :integer
      add :price_per_area, :float
    end
  end

  def down do
    alter table(:listings) do
      remove :orientation
      remove :floor_count
      remove :unit_per_floor
      remove :sun_period
      remove :elevators
      remove :construction_year
      remove :price_per_area
    end
  end
end
