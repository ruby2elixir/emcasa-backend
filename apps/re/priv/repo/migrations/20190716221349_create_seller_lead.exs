defmodule Re.Repo.Migrations.CreateSellerLead do
  use Ecto.Migration

  def change do
    create table(:seller_leads, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :source, :string
      add :complement, :string
      add :type, :string
      add :area, :string
      add :maintenance_fee, :float
      add :rooms, :integer
      add :bathrooms, :integer
      add :suites, :integer
      add :garage_spots, :integer
      add :value, :string
      add :tour_option, :utc_datetime

      add :address_uuid, references(:addresses, column: :uuid, type: :uuid)
      add :user_uuid, references(:seller_leads, column: :uuid, type: :uuid)

      timestamps(type: :timestamptz)
    end
  end
end
