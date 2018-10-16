defmodule Re.Repo.Migrations.RemoveListingsUsers do
  use Ecto.Migration

  def change do
    drop table(:listings_users)
  end
end
