defmodule Re.Repo.Migrations.DropCalendarDistricts do
  use Ecto.Migration

  def change do
    drop table(:calendar_districts)
  end
end
