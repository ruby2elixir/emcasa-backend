defmodule Re.Repo.Migrations.CreateBrokerSellerLeads do
  use Ecto.Migration

  def change do
    create table(:broker_seller_leads) do
      add :uuid, :uuid, primary_key: true
      add :broker_uuid, references(:users, column: :uuid, type: :uuid)
      add :address_uuid, references(:addresses, column: :uuid, type: :uuid)
      add :owner_uuid, references(:owner_contacts, column: :uuid, type: :uuid)
      add :complement, :string
      add :type, :string
      add :additional_information, :text
      add :utm, :jsonb, default: nil

      timestamps()
    end
  end
end
