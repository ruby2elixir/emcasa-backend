defmodule Re.Repo.Migrations.AddTourAppointmentDatetime do
  use Ecto.Migration

  def change do
    alter table(:tour_appointments) do
      add :option, :naive_datetime
    end
  end
end
