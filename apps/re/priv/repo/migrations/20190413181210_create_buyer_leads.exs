defmodule Re.Repo.Migrations.CreateBuyerLeads do
  use Ecto.Migration

  def change do
    create table(:buyer_leads, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :name, :string
      add :phone_number, :string
      add :email, :string
      add :origin, :string

      add :listing_uuid, references(:listings, column: :uuid, type: :uuid)
      add :user_uuid, references(:users, column: :uuid, type: :uuid)

      timestamps()
    end

    create index(:buyer_leads, [:listing_uuid, :user_uuid])
  end
end
