defmodule Re.Repo.Migrations.RemoveBlacklists do
  use Ecto.Migration

  def change do
    drop table(:listings_blacklists)
  end
end
