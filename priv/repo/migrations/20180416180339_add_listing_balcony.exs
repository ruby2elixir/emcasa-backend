defmodule Re.Repo.Migrations.AddListingBalcony do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :balconies, :integer
    end
  end
end
