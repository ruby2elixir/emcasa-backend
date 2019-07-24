defmodule Re.Repo.Migrations.AddCalendarsDepot do
  use Ecto.Migration

  def change do
    alter table(:calendars) do
      add :address_uuid, references(:addresses, column: :uuid, type: :uuid)
    end
  end
end
