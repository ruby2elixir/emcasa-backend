defmodule Re.Repo.Migrations.AddDuplicatedFieldToSellerLead do
  use Ecto.Migration

  def change do
    alter table(:seller_leads) do
      add :duplicated, :string
      add :duplicated_entities, :json, default: nil
    end
  end
end
