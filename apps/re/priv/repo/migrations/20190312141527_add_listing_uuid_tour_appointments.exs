defmodule Re.Repo.Migrations.AddListingUuidTourAppointments do
  use Ecto.Migration

  require Ecto.Query

  def up do
    alter table(:tour_appointments) do
      add :listing_uuid, references(:listings, column: :uuid, type: :uuid)
    end

    flush()

    execute("""
      UPDATE tour_appointments AS ta
      SET listing_uuid = l.uuid
      FROM listings AS l
      WHERE ta.listing_id = l.id
    """)

    flush()

    alter table(:tour_appointments) do
      remove :listing_id
    end
  end

  def down do
    alter table(:tour_appointments) do
      add :listing_id, references(:listings)
    end

    execute("""
      UPDATE tour_appointments AS ta
      SET listing_id = l.id
      FROM listings AS l
      WHERE ta.listing_uuid = l.uuid
    """)

    alter table(:tour_appointments) do
      remove :listing_uuid
    end
  end
end
