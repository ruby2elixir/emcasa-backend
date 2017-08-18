defmodule Re.Repo.Migrations.AddRoomsToListings do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :rooms, :integer
    end
  end
end
