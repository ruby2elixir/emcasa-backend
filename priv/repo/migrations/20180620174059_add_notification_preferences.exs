defmodule Re.Repo.Migrations.AddNotificationPreferences do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :notification_preferences, :map
    end

    flush()

    Re.Repo.update_all(Re.User, set: [notification_preferences: %Re.Accounts.NotificationPreferences{email: true, app: true, id: UUID.uuid4()}])
  end
end
