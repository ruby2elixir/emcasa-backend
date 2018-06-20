defmodule Re.Repo.Migrations.AddNotificationPreferences do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :notification_preferences, :map
    end
  end
end
