defmodule Re.Repo.Migrations.AddListingRestrooms do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :restrooms, :integer
    end
  end
end
