defmodule Re.Repo.Migrations.UpdateCalendarsShifts do
  use Ecto.Migration

  def change do
    alter table(:calendars) do
      remove :shift_start
      remove :shift_end
      add :shift_start, :time
      add :shift_end, :time
    end
  end
end
