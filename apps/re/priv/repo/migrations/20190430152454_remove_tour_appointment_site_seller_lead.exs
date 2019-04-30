defmodule Re.Repo.Migrations.RemoveTourAppointmentSiteSellerLead do
  use Ecto.Migration

  def change do
    alter table(:site_seller_leads) do
      remove :tour_appointment_id
    end
  end
end
