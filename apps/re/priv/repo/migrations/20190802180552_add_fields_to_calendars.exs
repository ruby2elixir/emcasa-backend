defmodule Re.Repo.Migrations.AddFieldsToCalendars do
  use Ecto.Migration

  def up do
    alter table(:calendars) do
      add(:name, :string)
      add(:speed, :string)
      modify(:external_id, :string, null: true)
    end
  end

  def down do
    alter table(:calendars) do
      remove :name
      remove :speed
      modify :external_id, :string, null: false
    end
  end
end
