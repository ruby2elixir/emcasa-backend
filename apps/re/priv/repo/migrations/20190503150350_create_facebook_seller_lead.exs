defmodule Re.Repo.Migrations.CreateFacebookSellerLead do
  use Ecto.Migration

  def change do
    create table(:facebook_seller_leads) do
      add :uuid, :uuid, primary_key: true
      add :full_name, :string
      add :email, :string
      add :phone_number, :string
      add :neighborhoods, :string
      add :objective, :string
      add :timestamp, :utc_datetime
      add :lead_id, :string
      add :location, :string

      timestamps()
    end
  end
end
