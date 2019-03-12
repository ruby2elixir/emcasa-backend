defmodule Re.Repo.Migrations.AddListingUuidTourAppointments do
  use Ecto.Migration

  def up do
    alter table(:tour_appointments) do
      add :listing_uuid, references(:listings, column: :uuid, type: :uuid)
    end

    flush()

    Re.Calendars.TourAppointment
    |> Ecto.Query.preload(:listing)
    |> Re.Repo.all()
    |> Enum.each(&set_uuid/1)
  end

  defp set_uuid(tour_appointment) do
    listing = Re.Repo.get(Re.Listing, tour_appointment.listing_id)

    {:ok, _} =
      tour_appointment
      |> Re.Calendars.TourAppointment.changeset(%{listing_uuid: listing.uuid})
      |> Re.Repo.update()
  end

  def down do
    alter table(:tour_appointments) do
      remove :listing_uuid
    end
  end
end
