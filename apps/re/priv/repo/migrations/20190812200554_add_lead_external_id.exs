defmodule Re.Repo.Migrations.AddLeadExternalId do
  use Ecto.Migration

  def change do
    alter table(:seller_leads) do
      add :salesforce_id, :string
    end

    create unique_index(:seller_leads, [:salesforce_id])
  end
end
