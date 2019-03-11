defmodule Re.Repo.Migrations.CreateRealEstate do
  use Ecto.Migration

  def change do
    create table(:real_estate) do
      add :uuid, :string
      add :complement, :string
      add :price, :integer
      add :property_tax, :float
      add :maintenance_fee, :float
      add :floor, :string
      add :rooms, :integer
      add :bathrooms, :integer
      add :restrooms, :integer
      add :area, :integer
      add :garage_spots, :integer
      add :garage_type, :string
      add :suites, :integer
      add :dependencies, :integer
      add :balconies, :integer

      add :listing_id, references(:listings)
    end

    create(unique_index(:real_estate, [:uuid]))
  end
end
