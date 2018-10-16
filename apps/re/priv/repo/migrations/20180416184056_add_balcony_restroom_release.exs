defmodule Re.Repo.Migrations.AddBalconyRestoroomRelease do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :balconies, :integer
      add :restrooms, :integer
      add :is_release, :boolean
    end
  end
end
