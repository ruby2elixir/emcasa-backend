defmodule Re.Repo.Migrations.AddFacebookBuyerLeads do
  use Ecto.Migration

  def change do
    create table(:facebook_buyer_leads, primary_key: false) do
      add :uuid, :uuid
      add :full_name, :string
      add :email, :string
      add :phone_number, :string
      add :neighborhoods, :string
      add :timestamp, :utc_datetime
      add :lead_id, :string
      add :location, :string

      timestamps()
    end
  end
end
