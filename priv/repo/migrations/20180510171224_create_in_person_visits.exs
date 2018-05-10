defmodule Re.Repo.Migrations.CreateInPersonVisits do
  use Ecto.Migration

  def change do
    create table(:in_person_visits) do
      add(:listing_id, references(:listings))
      add(:date, :utc_datetime)

      timestamps()
    end

    create(index(:in_person_visits, [:listing_id]))
  end
end
