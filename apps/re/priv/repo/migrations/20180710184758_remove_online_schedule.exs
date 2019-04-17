defmodule Re.Repo.Migrations.RemoveOnlineSchedule do
  use Ecto.Migration

  def up do
    alter table(:interest_types) do
      add :enabled, :boolean
    end
  end

  def down do
    alter table(:interest_types) do
      remove :enabled
    end
  end
end
