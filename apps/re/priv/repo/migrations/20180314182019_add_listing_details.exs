defmodule Re.Repo.Migrations.AddListingDetails do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :suites, :integer
      add :dependencies, :integer
      add :has_elevator, :boolean
    end
  end
end
