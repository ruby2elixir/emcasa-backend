defmodule Re.Repo.Migrations.AddExclusiveListing do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :is_exclusive, :boolean
    end

    flush()
    Re.Repo.update_all(Re.Listing, set: [is_exclusive: false])
  end
end
