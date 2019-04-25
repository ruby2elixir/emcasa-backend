defmodule Re.Repo.Migrations.CreateSiteSellerLeads do
  use Ecto.Migration

  def change do
    create table(:site_seller_leads, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :complement, :string
      add :type, :string
      add :maintenance_fee, :float
      add :suites, :integer
      add :price, :integer

      add :price_request_id, references(:price_suggestion_requests)
      add :tour_appointment_id, references(:tour_appointments)

      timestamps()
    end

    create index(:site_seller_leads, [:price_request_id, :tour_appointment_id])
  end
end
