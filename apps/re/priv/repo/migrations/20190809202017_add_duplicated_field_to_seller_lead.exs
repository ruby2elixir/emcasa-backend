defmodule Re.Repo.Migrations.AddDuplicatedFieldToSellerLead do
  use Ecto.Migration

  def change do
    alter table(:seller_leads) do
      add :duplicated, :string
      add :duplicated_entities, {:array, :map}, default: nil
    end
  end
end
