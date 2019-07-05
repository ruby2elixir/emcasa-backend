defmodule Re.Repo.Migrations.CreateWalkinOfflineBuyerLead do
  use Ecto.Migration

  def change do
    create table(:walking_offline_buyer_leads, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :full_name, :string
      add :email, :string
      add :phone_number, :string
      add :neighborhoods, :string
      add :timestamp, :utc_datetime
      add :location, :string
      add :cpf, :string
      add :where_did_you_find_about, :string

      timestamps(type: :timestamptz)
    end
  end
end
