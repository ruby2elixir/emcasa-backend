defmodule Re.Repo.Migrations.AddCalendarsDepot do
  use Ecto.Migration

  def change do
    alter table(:calendars) do
      add :address_id, references(:addresses)
    end
  end
end
