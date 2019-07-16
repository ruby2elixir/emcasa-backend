defmodule Re.Repo.Migrations.CreateSellerLead do
  use Ecto.Migration

  def change do
    create table(:seller_leads, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :street, :string
      add :street_number, :string
      add :city, :string
      add :state, :string
      add :neighborhood, :string
      add :postal_code, :string
      add :name, :string
      add :phone, :string
      add :email, :string
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

      timestamps(type: :timestamptz)
    end
  end
end
