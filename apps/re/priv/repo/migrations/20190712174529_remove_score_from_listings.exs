defmodule Re.Repo.Migrations.RemoveScoreFromListings do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      remove :score
    end
  end
end
