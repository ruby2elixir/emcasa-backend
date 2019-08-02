defmodule Re.Repo.Migrations.AddFieldsToCalendars do
  use Ecto.Migration

  def change do
    alter table(:calendars) do
      add(:name, :string)
      add(:speed, :string)
      modify(:external_id, :string, null: true)
    end
  end
end
