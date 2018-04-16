defmodule Re.Repo.Migrations.AddListingRelease do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :is_release, :boolean
    end
  end
end
