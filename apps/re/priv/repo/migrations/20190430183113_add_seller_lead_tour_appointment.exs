defmodule Re.Repo.Migrations.AddSellerLeadTourAppointment do
  use Ecto.Migration

  def change do
    alter table(:tour_appointments) do
      add :site_seller_lead_uuid, references(:site_seller_leads, type: :uuid, column: :uuid)
    end

    create index(:tour_appointments, [:site_seller_lead_uuid])
  end
end
