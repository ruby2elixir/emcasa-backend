defmodule Re.Repo.Migrations.AddTypesToCalendars do
  use Ecto.Migration

  def change do
    alter table(:calendars) do
      add :types, {:array, :string}
    end
  end
end
