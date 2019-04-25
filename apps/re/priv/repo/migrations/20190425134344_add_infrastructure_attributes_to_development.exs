defmodule Re.Repo.Migrations.AddInfrastructureAttributesToDevelopment do
  use Ecto.Migration

  def change do
    alter table(:developments) do
      add :floor_count, :integer
      add :units_per_floor, :integer
      add :elevators, :integer
    end
  end
end
