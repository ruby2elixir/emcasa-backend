defmodule Re.Repo.Migrations.CreateTourAppointments do
  use Ecto.Migration

  def change do
    create table(:tour_appointments) do
      add(:wants_pictures, :boolean)
      add(:wants_tour, :boolean)
      add(:options, :jsonb, default: "[]")

      add(:user_id, references(:users))
      add(:listing_id, references(:listings))

      timestamps()
    end

    create(index(:tour_appointments, [:user_id]))
    create(index(:tour_appointments, [:listing_id]))
  end
end
