defmodule Re.Repo.Migrations.AddGarageSpotsToListing do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :garage_spots, :integer
    end
  end
end
