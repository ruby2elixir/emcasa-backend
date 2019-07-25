defmodule Re.Repo.Migrations.CreateCalendars do
  use Ecto.Migration

  def change do
    create table(:calendars, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :external_id, :string, null: false
      add :shift_start, :time, null: false
      add :shift_end, :time, null: false

      timestamps()
    end

    create table(:calendar_districts, primary_key: false) do
      add :calendar_uuid, references(:calendars, column: :uuid, type: :uuid), primary_key: true
      add :district_uuid, references(:districts, column: :uuid, type: :uuid), primary_key: true
    end
  end
end
