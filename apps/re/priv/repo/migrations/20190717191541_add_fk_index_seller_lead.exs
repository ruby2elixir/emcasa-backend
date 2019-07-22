defmodule Re.Repo.Migrations.FixSellerLeadUserReference do
  use Ecto.Migration

  def up do
    alter table(:seller_leads) do
      remove :user_uuid
    end

    flush()

    alter table(:seller_leads) do
      add :user_uuid, references(:users, column: :uuid, type: :uuid)
    end

    create index(:seller_leads, [:address_uuid, :user_uuid])
  end

  def down do
    alter table(:seller_leads) do
      remove :user_uuid
    end

    drop index(:seller_leads, [:address_uuid, :user_uuid])
  end
end
