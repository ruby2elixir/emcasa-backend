defmodule Re.Repo.Migrations.AddListingUuidTourAppointments do
  use Ecto.Migration

  require Ecto.Query

  def up do
    alter table(:tour_appointments) do
      add :listing_uuid, references(:listings, column: :uuid, type: :uuid)
    end

    alter table(:tour_appointments) do
      remove :listing_id
    end
  end

  def down do
    alter table(:tour_appointments) do
      add :listing_id, references(:listings)
    end

    alter table(:tour_appointments) do
      remove :listing_uuid
    end
  end
end
