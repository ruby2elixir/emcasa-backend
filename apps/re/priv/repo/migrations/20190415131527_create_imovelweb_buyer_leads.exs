defmodule Re.Repo.Migrations.CreateImovelwebBuyerLeads do
  use Ecto.Migration

  def change do
    create table(:imovelweb_buyer_leads, primary_key: false) do
      add(:uuid, :uuid, primary_key: true)
      add :phone, :string
      add :name, :string
      add :listing_id, :string
      add :email, :string

      timestamps()
    end
  end
end
