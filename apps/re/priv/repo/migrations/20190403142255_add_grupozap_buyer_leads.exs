defmodule Re.Repo.Migrations.AddGrupozapBuyerLeads do
  use Ecto.Migration

  def change do
    create table(:grupozap_buyer_leads, primary_key: false) do
      add :uuid, :uuid
      add :lead_origin, :string
      add :timestamp, :utc_datetime
      add :origin_lead_id, :string
      add :origin_listing_id, :string
      add :client_listing_id, :string
      add :name, :string
      add :email, :string
      add :ddd, :string
      add :phone, :string
      add :message, :string

      timestamps()
    end
  end
end
